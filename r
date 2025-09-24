import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

import static org.springframework.boot.gradle.plugin.SpringBootPlugin.BOM_COORDINATES

plugins {
    id "java"
    alias libs.plugins.spring.boot apply false
    alias libs.plugins.dependency.management
    alias libs.plugins.kotlin.spring
    alias libs.plugins.kotlin.jpa
    alias libs.plugins.kotlin.jvm
    alias libs.plugins.sonarqube
    alias libs.plugins.node.gradle
    alias libs.plugins.qameta.allure
    alias libs.plugins.jib apply false
}

apply {
    plugin libs.plugins.sonarqube.get().pluginId
    from "ext.gradle"
}

allprojects {
    apply {
        plugin libs.plugins.dependency.management.get().pluginId
        plugin libs.plugins.kotlin.jvm.get().pluginId
        plugin libs.plugins.kotlin.spring.get().pluginId
        plugin libs.plugins.kotlin.jpa.get().pluginId
        plugin "java"
        plugin "jacoco"
    }

    group = 'ru.sber.poirot'
    version = projectVersion
    sourceCompatibility = javaSource
    targetCompatibility = javaTarget

    repositories repos

    dependencies {
        implementation "com.fasterxml.jackson.module:jackson-module-kotlin",
                "org.jetbrains.kotlin:kotlin-reflect",
                "org.jetbrains.kotlin:kotlin-stdlib-jdk8",
                "org.jetbrains.kotlinx:kotlinx-coroutines-core",
                "org.jetbrains.kotlinx:kotlinx-coroutines-reactor",
                "ch.qos.logback:logback-classic"

        testImplementation libs.spring.mockk,
                libs.bundles.allure.sber

        testImplementation('org.springframework.boot:spring-boot-starter-test') {
            exclude group: 'org.junit.vintage', module: 'junit-vintage-engine'
        }

        if (allureOn || !isLocal()) {
            apply plugin: 'io.qameta.allure'
            testImplementation libs.bundles.allure

            def allureGroup = 'allure'
            tasks.allureReport.group = allureGroup
            tasks.allureServe.group = allureGroup
        }
    }

    dependencyManagement {
        imports {
            mavenBom BOM_COORDINATES
            mavenBom "org.springframework.cloud:spring-cloud-dependencies:${libs.versions.spring.cloud.get()}"
        }
    }

    sourceSets {
        main.kotlin.srcDirs += 'src/main/kotlin'
        main.java.srcDirs += 'src/main/kotlin'
        test.java.srcDirs += 'src/test/kotlin'
        main.kotlin.srcDirs += 'src/main/generated'
        main.java.srcDirs += 'src/main/generated'

        main.java.exclude 'ru/sber/poirot/engine/retail/**'
        main.kotlin.exclude 'ru/sber/poirot/engine/retail/**'

        main.java.exclude 'ru/sber/engine/rulesinfo/**'
        main.kotlin.exclude 'ru/sber/engine/rulesinfo/**'

        test.java.exclude 'ru/sber/poirot/engine/retail/**'
        test.kotlin.exclude 'ru/sber/poirot/engine/retail/**'

        if (List.of("-18893500", "-16805899", "-19041483", "20812447").stream().noneMatch(System.getProperty("user.name", "system")::endsWith)) {
            test.java.exclude 'ru/sber/poirot/engine/cib/rules/**'
            test.kotlin.exclude 'ru/sber/poirot/engine/cib/rules/**'
        }
    }

    tasks.withType(AbstractArchiveTask) {
        preserveFileTimestamps = false
        reproducibleFileOrder = true
    }

    test {
        tasks.withType(Test) {
            outputs.upToDateWhen { true }
        }
        useJUnitPlatform()
        jvmArgs '--add-opens', 'java.xml/com.sun.org.apache.xerces.internal.jaxp.datatype=ALL-UNNAMED'
        /*dream jaxb reflection comparison*/
        jvmArgs '--add-opens', 'java.base/java.lang.reflect=ALL-UNNAMED' /*feed mockk tests*/
        exclude '**/*IT.class'
        if (List.of("-18893500", "-16805899", "-19041483").stream().noneMatch(System.getProperty("user.name", "system")::endsWith)) {
            exclude 'ru/sber/poirot/engine/cib/rules/**'
            exclude 'ru/sber/poirot/engine/cib/oldrules/**'
            exclude 'ru/sber/poirot/engine/retail/rules/**'
        }
        systemProperty('allure.results.directory', rootDir.absolutePath + "/build/allure-results")
        jvmArgs '--enable-preview'

        minHeapSize = "1024m"
        maxHeapSize = "2048m"

        testLogging {
            showStandardStreams = true
        }
    }

    tasks.withType(KotlinCompile).all {
        kotlinOptions {
            freeCompilerArgs = ["-Xjsr305=strict", "-Xjvm-default=all"]
            jvmTarget = javaTarget
        }
    }

    sonarqube {
        properties {
            property "sonar.sources", "src"
            property "sonar.binaries", "build/classes"
            property "sonar.inclusions", "**/src/main/kotlin/**/*.kt"
            property "sonar.exclusions", "**/jaxb/**/*.java, **/poirot/engine/**, **/poirot/strategies/**"
        }
    }


    afterEvaluate {
        if (project.pluginManager.hasPlugin("com.google.cloud.tools.jib")) {
            (registryUsername, registryPassword) = jibCredentials()
            jib {
                from {
                    image registryBaseImage
                    auth {
                        username registryUsername
                        password registryPassword
                    }
                }
                to {
                    def registry = isLocal() ? testRegistryRepository : registryRepository
                    def ver
                    if (isLocal()) {
                        final gitUserEmail = "git config user.email".execute().text.trim()
                        final gitBranchName = "git rev-parse --abbrev-ref HEAD".execute().text.trim()
                        ver = (gitUserEmail +'__' + gitBranchName)
                                .replaceAll("[ /@,]", "_")
                                .replaceAll("[^a-zA-Z0-9\\.\\-_]", "")
                                .replaceAll("^[\\.\\-_]*", "")
                                .replaceAll("[\\.\\-_]*\$", "")
                                .replaceAll("\\.{3,}", "..")
                                .replaceAll("\\-{3,}", "--")
                                .replaceAll("_{3,}", "__")
                    } else {
                        ver = project.version
                    }
                    image registry + project.name + ':' + ver
                    auth {
                        username registryUsername
                        password registryPassword
                    }
                }
                allowInsecureRegistries true
            }
        }
        npmInstall.args = ['--userconfig=/home/jenkins/agent/workspace/poirot/rc/.npmrc', '--verbose']
    }
}
pluginManagement {
    apply from: 'ext.gradle'
    repositories repos
}

rootProject.name = "poirot"

include ":services:ai:ai-agent",
        ":services:ai:ai-agent-backend",
        ":services:ai:ai-agent-patcher",
        ":services:ai:ai-agent-terminal-client",
        ":services:ai:ai-shared"

include ":services:infra:gateway",
        ":services:infra:spring-boot-admin"

include ":services:infra:audit-service:audit",
        ":services:infra:audit-service:audit-patcher"

include ":services:infra:file-storage-service:file-storage",
        ":services:infra:file-storage-service:file-storage-patcher"

include ":services:infra:healthcheck:healthchecker",
        ":services:infra:healthcheck:healthchecker-patcher"

include ":services:infra:second-hand:second-hand-control",
        ":services:infra:second-hand:second-hand-patcher"

include ":services:infra:accounts:scim-adapter",
        ":services:infra:accounts:users-patcher",
        ":services:infra:accounts:users"

include ":services:transport:ckp-online",
        ":services:transport:ckp-online-patcher",
        ":services:transport:dream",
        ":services:transport:dream-patcher",
        ":services:transport:score-result-api",
        ":services:transport:score-result-api-patcher",
        ":services:transport:scanner:scanner-app-uploader",
        ":services:transport:scanner:scanner-epk-adapter",
        ":services:transport:scanner:scanner-re-proxy",
        ":services:transport:scanner:sync-scanner",
        ":services:transport:scanner:scanner-shared",
        ":services:transport:recalculation",
        ":services:transport:recalculation-patcher",
        ":services:transport:clients-loader",
        ":services:transport:clients-loader-patcher",
        ":services:transport:negatives-loader",
        ":services:transport:negatives-loader-patcher",
        ":services:transport:problem-event",
        ":services:transport:problem-event-patcher",
        ":services:transport:ratings-le-online",
        ":services:transport:ratings-le-online-json",
        ":services:transport:ratings-le-patcher",
        ":services:transport:helpers:b3-framework",
        ":services:transport:helpers:dream-mocks",
        ":services:transport:helpers:epk-transformer",
        ":services:transport:helpers:kful-transformer",
        ":services:transport:helpers:recalculation-mocks",
        ":services:transport:helpers:request-workflow",
        ":services:transport:helpers:integration-tests-helpers",
        ":services:transport:smd-metadata-sender",
        ":services:transport:smd-metadata-sender-patcher",
        ":services:transport:loops:cycle-operations",
        ":services:transport:loops:cycle-operations-patcher",
        ":services:transport:loops:cycle-operations-pkap-patcher"

include ":services:transport:feeds:supermarket",
        ":services:transport:feeds:supermarket-patcher",
        ":services:transport:feeds:pkap-logging",
        ":services:transport:feeds:pkap-logging-patcher",
        ":services:transport:feeds:prometheus-feed",
        ":services:transport:feeds:prometheus-feed-patcher",
        ":services:transport:feeds:soc",
        ":services:transport:feeds:soc-patcher",
        ":services:transport:feeds:moncr-back-feed",
        ":services:transport:feeds:moncr-back-feed-patcher"

include ":services:transport:feeds:digital:digital-trace",
        ":services:transport:feeds:digital:digital-trace-patcher",
        ":services:transport:feeds:digital:digital-trace-transport-patcher"

include ":services:transport:documents:documents-loader",
        ":services:transport:documents:documents-loader-model",
        ":services:transport:documents:documents-loader-patcher"

include ":services:transport:dis-pro:dis-pro-patcher",
        ":services:transport:dis-pro:dis-pro-adapter",
        ":services:transport:dis-pro:dis-pro-model"

include ":services:transport:feeds:prometheus-metrics:prometheus-metrics-feed",
        ":services:transport:feeds:prometheus-metrics:prometheus-metrics-feed-patcher"

include ":services:transport:inheritance:inheritance",
        ":services:transport:inheritance:inheritance-patcher:inheritance-poirot-patcher",
        ":services:transport:inheritance:inheritance-patcher:inheritance-transport-patcher"

include ":re:re-core",
        ":re:rules-api",
        ":re:rules-testing"

include ":services:engine:model:model-api",
        ":services:engine:model:model-impl",
        ":services:engine:model:meta-model",
        ":services:engine:model:dictionaries"

include ":services:engine:cib:cib-rule-engine",
        ":services:engine:cib:cib-cache-node",
        ":services:engine:cib:cib-rule-engine-patcher",
        ":services:engine:cib:cib-rule-engine-patcher:cib-rule-engine-ai-model-patcher",
        ":services:engine:cib:cib-rule-engine-patcher:cib-rule-engine-bir-patcher",
        ":services:engine:cib:cib-rule-engine-patcher:cib-rule-engine-moonprism-patcher",
        ":services:engine:cib:cib-rule-engine-patcher:cib-rule-engine-pkap-patcher",
        ":services:engine:cib:fpvd-model-patcher",
        ":services:engine:cib:cib-rules",
        ":services:engine:cib:cib-scores-partitioner",
        ":services:engine:cib:address",
        ":services:engine:cib:scorings:degl-offline",
        ":services:engine:cib:scorings:moncr",
        ":services:engine:cib:scorings:uniscore",
        ":services:engine:cib:scorings:offline-workflow",
        ":services:engine:cib:scorings:stream-offline-workflow",
        ":services:engine:cib:scorings:ckp-offline",
        ":services:engine:cib:scorings:offline-keeper",
        ":services:engine:cib:scorings:mmb-full-approved",
        ":services:engine:cib:scorings:scorings-patcher",
        ":services:engine:cib:cib-links",
        ":services:engine:cib:scorings:live-scoring:live-scoring-scorer",
        ":services:engine:cib:scorings:live-scoring:live-scoring",
        ":services:engine:cib:scorings:live-scoring:live-scoring-patcher"

include ":services:engine:cib:ratings:ratings-patcher",
        ":services:engine:cib:ratings:ratings-le",
        ":services:engine:cib:ratings:ratings-batch",
        ":services:engine:cib:ratings:ratings-fin-state",
        ":services:engine:cib:ratings:ratings-maspers",
        ":services:engine:cib:ratings:ratings-limit",
        ":services:engine:cib:ratings:ratings-tax"

include ":services:frontback:engine-frontback",
        ":services:frontback:frontback-patcher",
        ":services:frontback:ui",
        ":services:frontback:der",
        ":services:frontback:dis-adapter",
        ":services:frontback:focus-monitoring",
        ":services:frontback:ratings-le-offline",
        ":services:frontback:arbitration",
        ":services:frontback:sources",
        ":services:frontback:fraud",
        ":services:frontback:deviation",
        ":services:frontback:reports",
        ":services:frontback:basket",
        ":services:frontback:dossier"

include ":services:frontback:pcf:pcf-monitoring",
        ":services:frontback:pcf:pcf-patcher"

include ":services:frontback:helpers:sync-rule-engine",
        ":services:frontback:helpers:ktor-client",
        ":services:frontback:helpers:business:order345",
        ":services:frontback:helpers:frontback-refreshables",
        ":services:frontback:helpers:dis:dis-adapter-client",
        ":services:frontback:helpers:dis:dis-pro-adapter-client",
        ":services:frontback:helpers:dis:dis-adapter-parallel-run",
        ":services:frontback:helpers:dis:reassignment",
        ":services:frontback:helpers:dis:sla",
        ":services:frontback:helpers:dis:sla-prolongation",
        ":services:frontback:helpers:dis:dto",
        ":services:frontback:helpers:shared-dictionaries",
        ":services:frontback:helpers:utils",
        ":services:frontback:helpers:test-utils",
        ":services:frontback:helpers:base-dependencies",
        ":services:frontback:helpers:filtration",
        ":services:frontback:helpers:business:unified-basket:unified-basket-provider",
        ":services:frontback:helpers:business:unified-basket:unified-basket-dto",
        ":services:frontback:helpers:infra:user-info-provider",
        ":services:frontback:helpers:infra:task-file-client",
        ":services:frontback:helpers:scoring:batch-scoring",
        ":services:transport:helpers:scoring:client-transport-model",
        ":services:frontback:helpers:scoring:rule-engine-client",
        ":services:frontback:helpers:scoring:rule-engine-scoring",
        ":services:frontback:helpers:business:frauds:fraud-signs",
        ":services:frontback:helpers:business:frauds:fraud-client",
        ":services:frontback:helpers:business:suspicion-manager",
        ":services:frontback:helpers:pdf",
        ":services:frontback:helpers:documents-client",
        ":services:frontback:helpers:business:process-shared"

include ":services:frontback:notification-service:notifications",
        ":services:frontback:notification-service:notifications-patcher"

include ":shared:patcher",
        ":shared:allure",
        ":shared:test-db-patcher",
        ":shared:test-micrometer",
        ":shared:property-source",
        ":shared:protobuf",
        ":shared:microservice-starter",
        ":shared:global-mutex",
        ":shared:kafka",
        ":shared:leader-election",
        ":shared:sidecar-shutdown",
        ":shared:csv-loader",
        ":shared:logs-downloader",
        ":shared:file-storage-client",
        ":shared:openapi-provider",
        ":shared:types"

include ":services:engine:helpers:transaction-tests",
        ":services:engine:helpers:poirot-model-generator",
        ":services:engine:helpers:dream-request-generator",
        ":services:engine:helpers:dictionaries-generator",
        ":services:engine:helpers:rules-analyzer",
        ":services:engine:helpers:stub-tests-generator",
        ":services:engine:helpers:poirot-score-comparator",
        ":services:engine:helpers:shared-comparator",
        ":services:engine:helpers:comparator-patcher",
        ":services:engine:helpers:rules-info-parser",
        ":services:engine:helpers:xml-rules-migrator",
        ":services:engine:helpers:rules-refreshables-mapper",
        ":services:engine:helpers:cache-keeper",
        ":services:engine:helpers:cib-utils",
        ":services:engine:helpers:refreshable-business-ui",
        ":services:engine:helpers:cache-keeper"

include ":shared:utils:convert-utils",
        ":shared:utils:dsl-utils",
        ":shared:utils:enrich-utils",
        ":shared:utils:io-utils",
        ":shared:utils:reflection-utils",
        ":shared:utils:xml-utils",
        ":shared:utils:json-utils",
        ":shared:utils:webflux-client",
        ":shared:utils:webflux-utils",
        ":shared:utils:http-nt",
        ":shared:utils:kotlin-funcs",
        ":shared:utils:anonymizer",
        ":shared:utils:class-definition",
        ":shared:utils:sql-utils",
        ":shared:utils:java-compiler",
        ":shared:utils:cache-utils",
        ":shared:utils:data-normalization"

include ":shared:framework:entity-persister",
        ":shared:framework:meta-model-generator",
        ":shared:framework:model-generator",
        ":shared:framework:offheap-collections",
        ":shared:framework:refreshable",
        ":shared:framework:dsl",
        ":shared:framework:dsl:datasources",
        ":shared:framework:dsl-metrics-ui",
        ":shared:framework:db-queue",
        ":shared:framework:coroutine-batch",
        ":shared:framework:async-client",
        ":shared:framework:partial-classes",
        ":shared:framework:mock-web-server",
        ":shared:framework:model-annotations"

include ":shared:security:resource-server",
        ":shared:security:permissions",
        ":shared:security:audit-client",
        ":shared:security:current-user"

include ":shared:front:exception-handler",
        ":shared:front:integration-test"

include ":shared:fault-tolerance:exception-handlers",
        ":shared:fault-tolerance:verification"

include ':usefull-scripts',
        ":usefull-scripts:atlassian-helper"

