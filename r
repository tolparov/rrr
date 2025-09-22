Picked up JAVA_TOOL_OPTIONS: -Xbootclasspath/a:/vault/secrets -Dapp.version=poirotPkapTestBuild-1.9739 -Dconfig.version=poirotPkapTestBuild-1.9739 -Dfile.encoding=UTF-8 -Dkotlinx.coroutines.io.parallelism=25 -XX:MaxDirectMemorySize=120M -XX:MaxRAMPercentage=31  -XX:+CrashOnOutOfMemoryError
16:42:17,971 |-INFO in ch.qos.logback.classic.LoggerContext[default] - This is logback-classic version 1.5.18
16:42:17,976 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 - Here is a list of configurators discovered as a service, by rank:
16:42:17,976 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 -   org.springframework.boot.logging.logback.RootLogLevelConfigurator
16:42:17,976 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 - They will be invoked in order until ExecutionStatus.DO_NOT_INVOKE_NEXT_IF_ANY is returned.
16:42:17,976 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 - Constructed configurator of type class org.springframework.boot.logging.logback.RootLogLevelConfigurator
16:42:17,997 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 - org.springframework.boot.logging.logback.RootLogLevelConfigurator.configure() call lasted 1 milliseconds. ExecutionStatus=INVOKE_NEXT_IF_ANY
16:42:17,998 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 - Trying to configure with ch.qos.logback.classic.joran.SerializedModelConfigurator
16:42:17,999 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 - Constructed configurator of type class ch.qos.logback.classic.joran.SerializedModelConfigurator
16:42:18,066 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback-test.scmo]
16:42:18,067 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback.scmo]
16:42:18,067 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 - ch.qos.logback.classic.joran.SerializedModelConfigurator.configure() call lasted 68 milliseconds. ExecutionStatus=INVOKE_NEXT_IF_ANY
16:42:18,067 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 - Trying to configure with ch.qos.logback.classic.util.DefaultJoranConfigurator
16:42:18,068 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 - Constructed configurator of type class ch.qos.logback.classic.util.DefaultJoranConfigurator
16:42:18,069 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback-test.xml]
16:42:18,073 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Found resource [logback.xml] at [file:/app/resources/logback.xml]
16:42:18,275 |-WARN in ch.qos.logback.core.joran.action.ConversionRuleAction - [converterClass] attribute is deprecated and replaced by [class]. See element [conversionRule] near line 5
16:42:18,275 |-WARN in ch.qos.logback.core.joran.action.ConversionRuleAction - [converterClass] attribute is deprecated and replaced by [class]. See element [conversionRule] near line 6
16:42:18,275 |-WARN in ch.qos.logback.core.joran.action.ConversionRuleAction - [converterClass] attribute is deprecated and replaced by [class]. See element [conversionRule] near line 7
16:42:18,467 |-INFO in ch.qos.logback.core.model.processor.TimestampModelHandler - Using current interpretation time, i.e. now, as time reference.
16:42:18,482 |-INFO in ch.qos.logback.core.model.processor.TimestampModelHandler - Adding property to the context with key="byDayHH" and value="20250922T164218" to the LOCAL scope
16:42:18,482 |-INFO in ch.qos.logback.core.model.processor.TimestampModelHandler - Using current interpretation time, i.e. now, as time reference.
16:42:18,483 |-INFO in ch.qos.logback.core.model.processor.TimestampModelHandler - Adding property to the context with key="byDay" and value="20250922" to the LOCAL scope
16:42:18,483 |-INFO in ch.qos.logback.core.model.processor.ConversionRuleModelHandler - registering conversion word clr with class [org.springframework.boot.logging.logback.ColorConverter]
16:42:18,483 |-INFO in ch.qos.logback.core.model.processor.ConversionRuleModelHandler - registering conversion word wex with class [org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter]
16:42:18,483 |-INFO in ch.qos.logback.core.model.processor.ConversionRuleModelHandler - registering conversion word wEx with class [org.springframework.boot.logging.logback.ExtendedWhitespaceThrowableProxyConverter]
16:42:18,488 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - Processing appender named [FILE]
16:42:18,488 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - About to instantiate appender of type [ch.qos.logback.core.rolling.RollingFileAppender]
16:42:18,677 |-INFO in c.q.l.core.rolling.SizeAndTimeBasedRollingPolicy@1414506856 - setting totalSizeCap to 1 GB
16:42:18,680 |-INFO in c.q.l.core.rolling.SizeAndTimeBasedRollingPolicy@1414506856 - Archive files will be limited to [100 MB] each.
16:42:18,680 |-INFO in c.q.l.core.rolling.SizeAndTimeBasedRollingPolicy@1414506856 - No compression will be used
16:42:18,684 |-INFO in c.q.l.core.rolling.SizeAndTimeBasedRollingPolicy@1414506856 - Will use the pattern logs/focus-monitoring.%d{yyyy-MM-dd}.%i.log for the active file
16:42:18,774 |-INFO in ch.qos.logback.core.rolling.SizeAndTimeBasedFileNamingAndTriggeringPolicy@247bddad - The date pattern is 'yyyy-MM-dd' from file name pattern 'logs/focus-monitoring.%d{yyyy-MM-dd}.%i.log'.
16:42:18,775 |-INFO in ch.qos.logback.core.rolling.SizeAndTimeBasedFileNamingAndTriggeringPolicy@247bddad - Roll-over at midnight.
16:42:18,781 |-INFO in ch.qos.logback.core.rolling.SizeAndTimeBasedFileNamingAndTriggeringPolicy@247bddad - Setting initial period to 2025-09-22T13:42:18.781Z
16:42:18,787 |-INFO in ch.qos.logback.core.rolling.RollingFileAppender[FILE] - Active log file name: logs/focus-monitoring.log
16:42:18,787 |-INFO in ch.qos.logback.core.rolling.RollingFileAppender[FILE] - File property is set to [logs/focus-monitoring.log]
16:42:18,788 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - Processing appender named [ASYNC_FILE]
16:42:18,788 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - About to instantiate appender of type [ch.qos.logback.classic.AsyncAppender]
16:42:18,791 |-INFO in ch.qos.logback.core.model.processor.AppenderRefModelHandler - Attaching appender named [FILE] to ch.qos.logback.classic.AsyncAppender[ASYNC_FILE]
16:42:18,791 |-INFO in ch.qos.logback.classic.AsyncAppender[ASYNC_FILE] - Attaching appender named [FILE] to AsyncAppender.
16:42:18,791 |-INFO in ch.qos.logback.classic.AsyncAppender[ASYNC_FILE] - Setting discardingThreshold to 1638
16:42:18,792 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - Processing appender named [STDOUT]
16:42:18,792 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - About to instantiate appender of type [ch.qos.logback.core.ConsoleAppender]
16:42:18,794 |-INFO in ch.qos.logback.core.model.processor.ImplicitModelHandler - Assuming default type [ch.qos.logback.classic.encoder.PatternLayoutEncoder] for [encoder] property
16:42:18,794 |-INFO in ch.qos.logback.core.ConsoleAppender[STDOUT] - BEWARE: Writing to the console can be very slow. Avoid logging to the
16:42:18,794 |-INFO in ch.qos.logback.core.ConsoleAppender[STDOUT] - console in production environments, especially in high volume systems.
16:42:18,794 |-INFO in ch.qos.logback.core.ConsoleAppender[STDOUT] - See also https://logback.qos.ch/codes.html#slowConsole
16:42:18,794 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - Processing appender named [ASYNC_STDOUT]
16:42:18,794 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - About to instantiate appender of type [ch.qos.logback.classic.AsyncAppender]
16:42:18,794 |-INFO in ch.qos.logback.core.model.processor.AppenderRefModelHandler - Attaching appender named [STDOUT] to ch.qos.logback.classic.AsyncAppender[ASYNC_STDOUT]
16:42:18,794 |-INFO in ch.qos.logback.classic.AsyncAppender[ASYNC_STDOUT] - Attaching appender named [STDOUT] to AsyncAppender.
16:42:18,794 |-INFO in ch.qos.logback.classic.AsyncAppender[ASYNC_STDOUT] - Setting discardingThreshold to 1638
16:42:18,795 |-INFO in ch.qos.logback.classic.model.processor.RootLoggerModelHandler - Setting level of ROOT logger to INFO
16:42:18,795 |-INFO in ch.qos.logback.core.model.processor.AppenderRefModelHandler - Attaching appender named [ASYNC_STDOUT] to Logger[ROOT]
16:42:18,795 |-INFO in ch.qos.logback.core.model.processor.AppenderRefModelHandler - Attaching appender named [ASYNC_FILE] to Logger[ROOT]
16:42:18,796 |-INFO in ch.qos.logback.classic.model.processor.LoggerModelHandler - Setting level of logger [org.flywaydb] to DEBUG
16:42:18,796 |-INFO in ch.qos.logback.classic.model.processor.LoggerModelHandler - Setting level of logger [com.zaxxer.hikari.HikariConfig] to ERROR
16:42:18,796 |-INFO in ch.qos.logback.classic.model.processor.LoggerModelHandler - Setting level of logger [ru.sber.poirot.engine.cib.offline.moncr.diff.sender.mutex] to DEBUG
16:42:18,796 |-INFO in ch.qos.logback.core.model.processor.DefaultProcessor@d35dea7 - End of configuration.
16:42:18,796 |-INFO in ch.qos.logback.classic.joran.JoranConfigurator@7770f470 - Registering current configuration as safe fallback point
16:42:18,796 |-INFO in ch.qos.logback.classic.util.ContextInitializer@3bd82cf5 - ch.qos.logback.classic.util.DefaultJoranConfigurator.configure() call lasted 728 milliseconds. ExecutionStatus=DO_NOT_INVOKE_NEXT_IF_ANY

16:42:20,471 |-WARN in ch.qos.logback.core.joran.action.ConversionRuleAction - [converterClass] attribute is deprecated and replaced by [class]. See element [conversionRule] near line 5
16:42:20,471 |-WARN in ch.qos.logback.core.joran.action.ConversionRuleAction - [converterClass] attribute is deprecated and replaced by [class]. See element [conversionRule] near line 6
16:42:20,471 |-WARN in ch.qos.logback.core.joran.action.ConversionRuleAction - [converterClass] attribute is deprecated and replaced by [class]. See element [conversionRule] near line 7
16:42:20,477 |-INFO in ch.qos.logback.core.model.processor.TimestampModelHandler - Using current interpretation time, i.e. now, as time reference.
16:42:20,477 |-INFO in ch.qos.logback.core.model.processor.TimestampModelHandler - Adding property to the context with key="byDayHH" and value="20250922T164220" to the LOCAL scope
16:42:20,477 |-INFO in ch.qos.logback.core.model.processor.TimestampModelHandler - Using current interpretation time, i.e. now, as time reference.
16:42:20,477 |-INFO in ch.qos.logback.core.model.processor.TimestampModelHandler - Adding property to the context with key="byDay" and value="20250922" to the LOCAL scope
16:42:20,477 |-INFO in ch.qos.logback.core.model.processor.ConversionRuleModelHandler - registering conversion word clr with class [org.springframework.boot.logging.logback.ColorConverter]
16:42:20,477 |-INFO in ch.qos.logback.core.model.processor.ConversionRuleModelHandler - registering conversion word wex with class [org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter]
16:42:20,477 |-INFO in ch.qos.logback.core.model.processor.ConversionRuleModelHandler - registering conversion word wEx with class [org.springframework.boot.logging.logback.ExtendedWhitespaceThrowableProxyConverter]
16:42:20,477 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - Processing appender named [FILE]
16:42:20,477 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - About to instantiate appender of type [ch.qos.logback.core.rolling.RollingFileAppender]
16:42:20,480 |-INFO in c.q.l.core.rolling.SizeAndTimeBasedRollingPolicy@1049590050 - setting totalSizeCap to 1 GB
16:42:20,480 |-INFO in c.q.l.core.rolling.SizeAndTimeBasedRollingPolicy@1049590050 - Archive files will be limited to [100 MB] each.
16:42:20,480 |-INFO in c.q.l.core.rolling.SizeAndTimeBasedRollingPolicy@1049590050 - No compression will be used
16:42:20,480 |-INFO in c.q.l.core.rolling.SizeAndTimeBasedRollingPolicy@1049590050 - Will use the pattern logs/focus-monitoring.%d{yyyy-MM-dd}.%i.log for the active file
16:42:20,481 |-INFO in ch.qos.logback.core.rolling.SizeAndTimeBasedFileNamingAndTriggeringPolicy@63192798 - The date pattern is 'yyyy-MM-dd' from file name pattern 'logs/focus-monitoring.%d{yyyy-MM-dd}.%i.log'.
16:42:20,481 |-INFO in ch.qos.logback.core.rolling.SizeAndTimeBasedFileNamingAndTriggeringPolicy@63192798 - Roll-over at midnight.
16:42:20,482 |-INFO in ch.qos.logback.core.rolling.SizeAndTimeBasedFileNamingAndTriggeringPolicy@63192798 - Setting initial period to 2025-09-22T13:42:18.787Z
16:42:20,482 |-INFO in ch.qos.logback.core.rolling.RollingFileAppender[FILE] - Active log file name: logs/focus-monitoring.log
16:42:20,486 |-INFO in ch.qos.logback.core.rolling.RollingFileAppender[FILE] - Setting currentFileLength to 0 for logs/focus-monitoring.log
16:42:20,486 |-INFO in ch.qos.logback.core.rolling.RollingFileAppender[FILE] - File property is set to [logs/focus-monitoring.log]
16:42:20,486 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - Processing appender named [ASYNC_FILE]
16:42:20,486 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - About to instantiate appender of type [ch.qos.logback.classic.AsyncAppender]
16:42:20,486 |-INFO in ch.qos.logback.core.model.processor.AppenderRefModelHandler - Attaching appender named [FILE] to ch.qos.logback.classic.AsyncAppender[ASYNC_FILE]
16:42:20,486 |-INFO in ch.qos.logback.classic.AsyncAppender[ASYNC_FILE] - Attaching appender named [FILE] to AsyncAppender.
16:42:20,486 |-INFO in ch.qos.logback.classic.AsyncAppender[ASYNC_FILE] - Setting discardingThreshold to 1638
16:42:20,487 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - Processing appender named [STDOUT]
16:42:20,487 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - About to instantiate appender of type [ch.qos.logback.core.ConsoleAppender]
16:42:20,487 |-INFO in ch.qos.logback.core.model.processor.ImplicitModelHandler - Assuming default type [ch.qos.logback.classic.encoder.PatternLayoutEncoder] for [encoder] property
16:42:20,491 |-INFO in ch.qos.logback.core.ConsoleAppender[STDOUT] - BEWARE: Writing to the console can be very slow. Avoid logging to the
16:42:20,491 |-INFO in ch.qos.logback.core.ConsoleAppender[STDOUT] - console in production environments, especially in high volume systems.
16:42:20,491 |-INFO in ch.qos.logback.core.ConsoleAppender[STDOUT] - See also https://logback.qos.ch/codes.html#slowConsole
16:42:20,491 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - Processing appender named [ASYNC_STDOUT]
16:42:20,491 |-INFO in ch.qos.logback.core.model.processor.AppenderModelHandler - About to instantiate appender of type [ch.qos.logback.classic.AsyncAppender]
16:42:20,491 |-INFO in ch.qos.logback.core.model.processor.AppenderRefModelHandler - Attaching appender named [STDOUT] to ch.qos.logback.classic.AsyncAppender[ASYNC_STDOUT]
16:42:20,491 |-INFO in ch.qos.logback.classic.AsyncAppender[ASYNC_STDOUT] - Attaching appender named [STDOUT] to AsyncAppender.
16:42:20,491 |-INFO in ch.qos.logback.classic.AsyncAppender[ASYNC_STDOUT] - Setting discardingThreshold to 1638
16:42:20,491 |-INFO in ch.qos.logback.classic.model.processor.RootLoggerModelHandler - Setting level of ROOT logger to INFO
16:42:20,491 |-INFO in ch.qos.logback.classic.jul.LevelChangePropagator@50eca7c6 - Propagating INFO level on Logger[ROOT] onto the JUL framework
16:42:20,492 |-INFO in ch.qos.logback.core.model.processor.AppenderRefModelHandler - Attaching appender named [ASYNC_STDOUT] to Logger[ROOT]
16:42:20,492 |-INFO in ch.qos.logback.core.model.processor.AppenderRefModelHandler - Attaching appender named [ASYNC_FILE] to Logger[ROOT]
16:42:20,492 |-INFO in ch.qos.logback.classic.model.processor.LoggerModelHandler - Setting level of logger [org.flywaydb] to DEBUG
16:42:20,492 |-INFO in ch.qos.logback.classic.jul.LevelChangePropagator@50eca7c6 - Propagating DEBUG level on Logger[org.flywaydb] onto the JUL framework
16:42:20,492 |-INFO in ch.qos.logback.classic.model.processor.LoggerModelHandler - Setting level of logger [com.zaxxer.hikari.HikariConfig] to ERROR
16:42:20,492 |-INFO in ch.qos.logback.classic.jul.LevelChangePropagator@50eca7c6 - Propagating ERROR level on Logger[com.zaxxer.hikari.HikariConfig] onto the JUL framework
16:42:20,493 |-INFO in ch.qos.logback.classic.model.processor.LoggerModelHandler - Setting level of logger [ru.sber.poirot.engine.cib.offline.moncr.diff.sender.mutex] to DEBUG
16:42:20,493 |-INFO in ch.qos.logback.classic.jul.LevelChangePropagator@50eca7c6 - Propagating DEBUG level on Logger[ru.sber.poirot.engine.cib.offline.moncr.diff.sender.mutex] onto the JUL framework
16:42:20,493 |-INFO in ch.qos.logback.core.model.processor.DefaultProcessor@58e6d4b8 - End of configuration.
16:42:20,493 |-INFO in org.springframework.boot.logging.logback.SpringBootJoranConfigurator@1de5f0ef - Registering current configuration as safe fallback point


  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/

 :: Spring Boot ::                (v3.4.6)

22.09 16:42:20.988  INFO [               main] r.s.p.focus.FocusMonitoringStarterKt    : Starting FocusMonitoringStarterKt using Java 17.0.7 with PID 1 (/app/classes started by 1004410000 in /home/jboss)
22.09 16:42:20.991  INFO [               main] r.s.p.focus.FocusMonitoringStarterKt    : No active profile set, falling back to 1 default profile: "default"
22.09 16:42:21.371  INFO [               main] r.s.p.PlatformPropertySourceFactory     : Waiting for secrets: [/vault/secrets/secret.properties] from SecMan.
22.09 16:42:22.373  INFO [               main] r.s.p.PlatformPropertySourceFactory     : Waiting for secrets: [/vault/secrets/secret.properties] from SecMan.
22.09 16:42:31.284  INFO [               main] faultConfiguringBeanFactoryPostProcessor: No bean named 'errorChannel' has been explicitly defined. Therefore, a default PublishSubscribeChannel will be created.
22.09 16:42:31.299  INFO [               main] faultConfiguringBeanFactoryPostProcessor: No bean named 'integrationHeaderChannelRegistry' has been explicitly defined. Therefore, a default DefaultHeaderChannelRegistry will be created.
22.09 16:42:34.207  INFO [               main] r.s.p.e.datasources.PoirotDataSource    : Registering HikariDataSource for poirot_pkap database
22.09 16:42:34.405  INFO [               main] com.zaxxer.hikari.HikariDataSource      : HikariPool-1 - Starting...
22.09 16:42:35.637  INFO [               main] com.zaxxer.hikari.pool.HikariPool       : HikariPool-1 - Added connection org.postgresql.jdbc.PgConnection@70916715
22.09 16:42:35.638  INFO [               main] com.zaxxer.hikari.HikariDataSource      : HikariPool-1 - Start completed.
22.09 16:42:35.797  INFO [               main] r.s.p.e.datasources.PoirotDataSource    : Registering HikariDataSource for poirot_bir database
22.09 16:42:35.992  INFO [               main] com.zaxxer.hikari.HikariDataSource      : HikariPool-2 - Starting...
22.09 16:42:36.555  INFO [               main] com.zaxxer.hikari.pool.HikariPool       : HikariPool-2 - Added connection org.postgresql.jdbc.PgConnection@28f33810
22.09 16:42:36.555  INFO [               main] com.zaxxer.hikari.HikariDataSource      : HikariPool-2 - Start completed.
22.09 16:42:36.580  INFO [               main] r.s.p.e.datasources.PoirotDataSource    : Registering HikariDataSource for poirot_moonprism database
22.09 16:42:36.700  INFO [               main] com.zaxxer.hikari.HikariDataSource      : HikariPool-3 - Starting...
22.09 16:42:37.106  INFO [               main] com.zaxxer.hikari.pool.HikariPool       : HikariPool-3 - Added connection org.postgresql.jdbc.PgConnection@290964bd
22.09 16:42:37.106  INFO [               main] com.zaxxer.hikari.HikariDataSource      : HikariPool-3 - Start completed.
22.09 16:42:38.595  INFO [               main] r.s.s.p.c.SequenceIncrementVerifier     : Ignore sequence increment check for schemes: [[]]
22.09 16:42:38.773  INFO [               main] r.s.s.p.c.SequenceIncrementVerifier     : Checked that incrementBy = 100 for 67 seqs: [arbitration.arbitration_agent_record_seq, arbitration.arbitration_record_seq, deviation.deviation_negatives_seq, deviation.deviation_participant_seq, deviation.deviation_record_seq, deviation.team_informations_seq, dis.reassignment_event_seq, dis.dis_record_seq, dis.sla_seq, dis.sla_prolongation_event_seq, re_documents.package_seq, re_documents.document_seq, re_documents.documents_request_seq, re_documents.file_seq, rule_engine.cache_seq, rule_engine.job_execution_log_seq, rule_engine.object_used_in_cache_seq, re_fraud.feature_seq, re_fraud.fraud_additional_info_seq, re_fraud.fraud_additional_info_date_seq, re_fraud.fraud_additional_info_history_seq, re_fraud.fraud_additional_info_history_date_seq, re_fraud.feature_history_seq, frontback.red_button_seq, frontback.user_file_info_seq, inheritance.inherited_deal_seq, inheritance.inherited_deal_content_seq, focus_monitoring.bank...
22.09 16:42:38.773  INFO [               main] r.s.s.p.c.SequenceIncrementVerifier     : Checked that incrementBy = 1 for 258 seqs: [re_dictionaries.ai_agent_prompts_id_seq, re_dictionaries.ai_agent_rule_hints_id_seq, re_dictionaries.app_status_corp_id_seq, re_dictionaries.app_status_exp_id_seq, re_dictionaries.app_status_ret_id_seq, re_dictionaries.app_status_sme_id_seq, re_dictionaries.arbitration_excluded_rules_id_seq, re_dictionaries.arbitration_for_ai_agent_id_seq, re_dictionaries.arbitration_reasons_id_seq, re_dictionaries.assd_dict_id_seq, re_dictionaries.assd_ignore_id_seq, re_dictionaries.assd_ignore_gryppa_id_seq, re_dictionaries.assd_ignore_k_7m_id_seq, re_dictionaries.ast_limit_gre_id_seq, re_dictionaries.ast_limit_sanction_list_id_seq, re_dictionaries.black_broker_fl_id_seq, re_dictionaries.black_broker_ul_id_seq, re_dictionaries.check_fraud_process_type_id_seq, re_dictionaries.check_fraud_roles_id_seq, re_dictionaries.ckp_offline_role_filter_id_seq, re_dictionaries.ckp_online_product_id_seq, ...
22.09 16:42:40.504  INFO [               main] r.s.p.e.d.refreshable.RefreshableConfig : Static micrometer initiated
22.09 16:42:40.596  INFO [               main] r.s.p.e.ds.refreshable.Refreshables     : Using heap collections for refreshables.
22.09 16:42:41.774  INFO [               main] org.reflections.Reflections             : Reflections took 1100 ms to scan 39 urls, producing 701 keys and 7356 values
22.09 16:42:43.288  INFO [         refresh-01] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'DslDictionaries.corpOkopfIgnore'. Limit: 1/10.
22.09 16:42:43.293  INFO [         refresh-02] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'DslDictionaries.inputSources'. Limit: 2/10.
22.09 16:42:43.293  INFO [         refresh-03] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'DslDictionaries.defaultProcessTypes'. Limit: 3/10.
22.09 16:42:43.293  INFO [         refresh-04] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'DslDictionaries.monitoringStatuses'. Limit: 4/10.
22.09 16:42:43.294  INFO [         refresh-05] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'DslDictionaries.inProcessFrauds'. Limit: 5/10.
22.09 16:42:43.294  INFO [         refresh-06] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'DslDictionaries.corpcustSegments'. Limit: 6/10.
22.09 16:42:43.294  INFO [         refresh-07] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'DslDictionaries.monitoringSlaByDefaults'. Limit: 7/10.
22.09 16:42:43.295  INFO [         refresh-08] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'Refreshables.ignoredIpStatuses'. Limit: 8/10.
22.09 16:42:43.595  INFO [         refresh-07] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'ReassignmentReasonsDict.disReassignmentReasons'. Limit: 10/10.
22.09 16:42:43.595  INFO [         refresh-03] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'SlaProlongationReasonsDict.disReassignmentReasons'. Limit: 10/10.
22.09 16:42:43.671  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(1) in 74 ms:
***
findAll(corpIgnoreIpStatus.status) where {
  corpIgnoreIpStatus.id is not null
}
SELECT input.index, corpIgnoreIpStatus_5.status
from (select generate_series(0, ?) as index) as input,
re_dictionaries.corp_ignore_ip_status corpIgnoreIpStatus_5
where corpIgnoreIpStatus_5.id is not null
***
22.09 16:42:43.671  INFO [         refresh-01] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(2) in 74 ms:
***
findAll(corpOkopfIgnore.value, batch = false, deduplicate = true) where {
  corpOkopfIgnore.id is not null
}
SELECT corpOkopfIgnore_7.value
from re_dictionaries.corp_okopf_ignore corpOkopfIgnore_7
where corpOkopfIgnore_7.id is not null
***
22.09 16:42:43.684  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(3) in 2 ms:
***
findAll(inputSource) fetchFields { listOf(inputSource.id, inputSource.source) } where {
  inputSource.id is not null
}
SELECT input.index, inputSource_3.id, inputSource_3.source
from (select generate_series(0, ?) as index) as input,
re_dictionaries.input_source inputSource_3
where inputSource_3.id is not null
***
22.09 16:42:43.684  INFO [         refresh-03] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(4) in 0 ms:
***
findAll(disSlaProlongationReasons, batch = false, deduplicate = true) fetchFields { listOf(disSlaProlongationReasons.id, disSlaProlongationReasons.code, disSlaProlongationReasons.description, disSlaProlongationReasons.prolongationTimeHours, disSlaProlongationReasons.processType) } where {
  sql("")
}
SELECT disSlaProlongationReasons_27.id, disSlaProlongationReasons_27.code, disSlaProlongationReasons_27.description, disSlaProlongationReasons_27.prolongation_time_hours, disSlaProlongationReasons_27.process_type
from re_dictionaries.dis_sla_prolongation_reasons disSlaProlongationReasons_27
***
22.09 16:42:43.685  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(5) in 0 ms:
***
findAll(monitoringSlaByDefault) fetchFields { listOf(monitoringSlaByDefault.id, monitoringSlaByDefault.durationInMinutes) } where {
  monitoringSlaByDefault.id is not null
}
SELECT input.index, monitoringSlaByDefault_6.id, monitoringSlaByDefault_6.duration_in_minutes
from (select generate_series(0, ?) as index) as input,
re_dictionaries.monitoring_sla_by_default monitoringSlaByDefault_6
where monitoringSlaByDefault_6.id is not null
***
22.09 16:42:43.685  INFO [         refresh-07] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(6) in 0 ms:
***
findAll(disReassignmentReasons, batch = false, deduplicate = true) fetchFields { listOf(disReassignmentReasons.id, disReassignmentReasons.code, disReassignmentReasons.description) } where {
  sql("")
}
SELECT disReassignmentReasons_28.id, disReassignmentReasons_28.code, disReassignmentReasons_28.description
from re_dictionaries.dis_reassignment_reasons disReassignmentReasons_28
***
22.09 16:42:43.685  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(7) in 0 ms:
***
findAll(monitoringStatus) fetchFields { listOf(monitoringStatus.id, monitoringStatus.status) } where {
  monitoringStatus.id is not null
}
SELECT input.index, monitoringStatus_0.id, monitoringStatus_0.status
from (select generate_series(0, ?) as index) as input,
re_dictionaries.monitoring_status monitoringStatus_0
where monitoringStatus_0.id is not null
***
22.09 16:42:43.688  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(8) in 2 ms:
***
findAll(defaultProcessType) fetchFields { listOf(defaultProcessType.id, defaultProcessType.processType) } where {
  defaultProcessType.id is not null
}
SELECT input.index, defaultProcessType_2.id, defaultProcessType_2.process_type
from (select generate_series(0, ?) as index) as input,
re_dictionaries.default_process_type defaultProcessType_2
where defaultProcessType_2.id is not null
***
22.09 16:42:43.689  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(9) in 1 ms:
***
findAll(inProcessFraud) fetchFields { listOf(inProcessFraud.id, inProcessFraud.fraud) } where {
  inProcessFraud.id is not null
}
SELECT input.index, inProcessFraud_1.id, inProcessFraud_1.fraud
from (select generate_series(0, ?) as index) as input,
re_dictionaries.in_process_fraud inProcessFraud_1
where inProcessFraud_1.id is not null
***
22.09 16:42:43.689  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(10) in 0 ms:
***
findAll(corpcustSegment.segment) where {
  corpcustSegment.id is not null
}
SELECT input.index, corpcustSegment_4.segment
from (select generate_series(0, ?) as index) as input,
re_dictionaries.corpcust_segment corpcustSegment_4
where corpcustSegment_4.id is not null
***
22.09 16:42:43.795  INFO [         refresh-07] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'ReassignmentReasonsDict.disReassignmentReasons'. Fetched 5 items in 0 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:43.806  INFO [         refresh-03] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'DslDictionaries.fraudSchemeCorps'. Limit: 10/10.
22.09 16:42:43.866  INFO [         refresh-01] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'DslDictionaries.corpOkopfIgnore'. Fetched 3 items in 1 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:43.868  INFO [         refresh-03] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(11) in 0 ms:
***
findAll(fraudReasonsCorp, batch = false, deduplicate = true) fetchFields { listOf(fraudReasonsCorp.key, fraudReasonsCorp.name, fraudReasonsCorp.id) } where {
  fraudReasonsCorp.id is not null
}
SELECT fraudReasonsCorp_37.key, fraudReasonsCorp_37.name, fraudReasonsCorp_37.id
from re_dictionaries.fraud_reasons_corp fraudReasonsCorp_37
where fraudReasonsCorp_37.id is not null
***
22.09 16:42:43.894  INFO [               main] p.e.d.r.o.RegistrationRefreshableFactory: Initialized 2/11 refreshables in 1 sec. Remaining(9): [RefreshableMap('DslDictionaries.monitoringSlaByDefaults'), RefreshableMap('SlaProlongationReasonsDict.disReassignmentReasons'), RefreshableSet('DslDictionaries.fraudSchemeCorps'), RefreshableMap('DslDictionaries.inProcessFrauds'), RefreshableSet('Refreshables.ignoredIpStatuses'), RefreshableMap('DslDictionaries.inputSources'), RefreshableMap('DslDictionaries.monitoringStatuses'), RefreshableMap('DslDictionaries.defaultProcessTypes'), RefreshableSet('DslDictionaries.corpcustSegments')]. CacheSize: 0 mb.
22.09 16:42:43.898  INFO [         refresh-01] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'SlaProlongationReasonsDict.disReassignmentReasons'. Fetched 4 items in 0 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:43.913  INFO [         refresh-01] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'DslDictionaries.inProcessFrauds'. Fetched 3 items in 1 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:43.929  INFO [         refresh-01] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'Refreshables.ignoredIpStatuses'. Fetched 2 items in 1 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:43.966  INFO [         refresh-01] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'DslDictionaries.monitoringStatuses'. Fetched 8 items in 1 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:43.981  INFO [         refresh-01] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'DslDictionaries.inputSources'. Fetched 2 items in 1 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:43.995  INFO [               main] p.e.d.r.o.RegistrationRefreshableFactory: Initialized 7/11 refreshables in 1 sec. Remaining(4): [RefreshableMap('DslDictionaries.monitoringSlaByDefaults'), RefreshableSet('DslDictionaries.fraudSchemeCorps'), RefreshableMap('DslDictionaries.defaultProcessTypes'), RefreshableSet('DslDictionaries.corpcustSegments')]. CacheSize: 0 mb.
22.09 16:42:43.997  INFO [         refresh-07] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'DslDictionaries.defaultProcessTypes'. Fetched 11 items in 1 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:43.998  INFO [         refresh-01] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'DslDictionaries.monitoringSlaByDefaults'. Fetched 3 items in 1 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:44.014  INFO [         refresh-07] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'DslDictionaries.corpcustSegments'. Fetched 12 items in 1 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:44.029  INFO [         refresh-07] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'DslDictionaries.fraudSchemeCorps'. Fetched 20 items in 0 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:44.095  INFO [               main] p.e.d.r.o.RegistrationRefreshableFactory: Initialized 11/11 refreshables in 1 sec. Remaining(0): []. CacheSize: 0 mb.
22.09 16:42:44.201  INFO [         refresh-01] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'UserInfoProviderImpl.userInfo: [BASKET_FOCUS_MONITORING, STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM, STATUS_AGREEMENT_FM, FM_FILE_EXECUTION, REGISTRY_FM, REGISTRY_FM_EMPLOYEE, EDIT_AGREED_FM, INITIATION_FOCUS_MONITORING, FM_AUTOLOAD_RECORDS, DELETE_TASK_FM]'. Limit: 1/10.
22.09 16:42:44.786  INFO [         refresh-07] r.s.p.e.d.r.core.AbstractRefreshable    : Going to refresh 'UserInfoProviderImpl.userInfo: [STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM]'. Limit: 2/10.
22.09 16:42:46.765  INFO [         refresh-07] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'UserInfoProviderImpl.userInfo: [STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM]'. Fetched 10 items in 2 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:46.774  INFO [         refresh-01] r.s.p.e.ds.refreshable.Refreshables     : Refreshable userInfo: [BASKET_FOCUS_MONITORING, STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM, STATUS_AGREEMENT_FM, FM_FILE_EXECUTION, REGISTRY_FM, REGISTRY_FM_EMPLOYEE, EDIT_AGREED_FM, INITIATION_FOCUS_MONITORING, FM_AUTOLOAD_RECORDS, DELETE_TASK_FM] is updated in 2572 ms.
22.09 16:42:46.774  INFO [         refresh-01] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'UserInfoProviderImpl.userInfo: [BASKET_FOCUS_MONITORING, STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM, STATUS_AGREEMENT_FM, FM_FILE_EXECUTION, REGISTRY_FM, REGISTRY_FM_EMPLOYEE, EDIT_AGREED_FM, INITIATION_FOCUS_MONITORING, FM_AUTOLOAD_RECORDS, DELETE_TASK_FM]'. Fetched 82 items in 3 sec. Size: 0 KB. Versions: 0 -> 1.
22.09 16:42:47.588  INFO [               main] org.reflections.Reflections             : Reflections took 984 ms to scan 39 urls, producing 701 keys and 7356 values
22.09 16:42:47.615  INFO [               main] ru.sber.poirot.cache.Cacheables         : Soft init cacheable cache managers, count: 3
22.09 16:42:48.987  INFO [               main] o.h.validator.internal.util.Version     : HV000001: Hibernate Validator 8.0.2.Final
22.09 16:42:50.295  INFO [               main] o.s.b.a.e.web.EndpointLinksResolver     : Exposing 6 endpoints beneath base path '/actuator'
22.09 16:42:51.965  INFO [               main] o.s.i.endpoint.EventDrivenConsumer      : Adding {logging-channel-adapter:_org.springframework.integration.errorLogger} as a subscriber to the 'errorChannel' channel
22.09 16:42:51.966  INFO [               main] o.s.i.channel.PublishSubscribeChannel   : Channel 'focus-monitoring.errorChannel' has 1 subscriber(s).
22.09 16:42:51.966  INFO [               main] o.s.i.endpoint.EventDrivenConsumer      : started bean '_org.springframework.integration.errorLogger'
22.09 16:42:51.979  INFO [               main] o.s.b.web.embedded.netty.NettyWebServer : Netty started on port 9365 (http)
22.09 16:42:52.001  INFO [               main] r.s.p.focus.FocusMonitoringStarterKt    : Started FocusMonitoringStarterKt in 32.987 seconds (process running for 34.49)
22.09 16:43:16.285  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(12) in 2 ms:
***
findAll(focusMonitoringRecord, orderBy = listOf(focusMonitoringRecord.dateCreate), batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.id) } where {
  focusMonitoringRecord.status = 1
  focusMonitoringRecord.dateCreate is null or focusMonitoringRecord.dateCreate >= ?
  focusMonitoringRecord.dateCreate <= ?
}
SELECT focusMonitoringRecord_233.id
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where (focusMonitoringRecord_233.status = 1 and
(focusMonitoringRecord_233.date_create is null or
(focusMonitoringRecord_233.date_create >= ? and
focusMonitoringRecord_233.date_create <= ?)))
order by focusMonitoringRecord_233.date_create asc
***
22.09 16:43:16.397  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 115 ms.
22.09 16:43:37.966  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(13) in 62 ms:
***
findAll(listOf(ibRegInfoEgrul.inn)) where {
  ibRegInfoEgrul.inn = any(?)
}
SELECT input.index, ibRegInfoEgrul_309.inn
from (select generate_series(0, ?) as index, unnest(?) as p0) as input,
dm_cib_bir098.ib_reg_info_egrul ibRegInfoEgrul_309
where ibRegInfoEgrul_309.inn = any(string_to_array(input.p0, 'ツ'))
***
22.09 16:43:38.005  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(14) in 0 ms:
***
findAll(listOf(leRegInfoEgrul.inn)) where {
  leRegInfoEgrul.inn = any(?)
}
SELECT input.index, leRegInfoEgrul_360.inn
from (select generate_series(0, ?) as index, unnest(?) as p0) as input,
dm_cib_bir098.le_reg_info_egrul leRegInfoEgrul_360
where leRegInfoEgrul_360.inn = any(string_to_array(input.p0, 'ツ'))
***
22.09 16:43:38.183  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(15) in 0 ms:
***
findAll(focusMonitoringRecord, batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.inn, focusMonitoringRecord.status, focusMonitoringRecord.processType) } where {
  focusMonitoringRecord.inn = any(?)
}
SELECT focusMonitoringRecord_233.inn, focusMonitoringRecord_233.status, focusMonitoringRecord_233.process_type
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where focusMonitoringRecord_233.inn = any(?)
***
22.09 16:43:38.189  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 51 ms.
22.09 16:43:38.254  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(16) in 0 ms:
***
findAll(listOf(defaultClient.inn, defaultClient.clientId), distinctOn = listOf(defaultClient.inn), orderBy = listOf(defaultClient.inn, defaultClient.beginDate), order = DESC, batch = false, deduplicate = true) where {
  defaultClient.inn = any(?)
  defaultClient.endDate is null
}
SELECT distinct on(defaultClient_421.inn) defaultClient_421.inn, defaultClient_421.client_id
from dm_cib_default.client defaultClient_421
where (defaultClient_421.inn = any(?) and
defaultClient_421.end_date is null)
order by defaultClient_421.inn desc, defaultClient_421.begin_date desc
***
22.09 16:43:38.307  INFO [Dispatcher-worker-2] ru.sber.poirot.coroutines.Dispatchers   : Init 1 'small' batch threads.
22.09 16:43:38.307  INFO [Dispatcher-worker-2] ru.sber.poirot.coroutines.Dispatchers   : Init 1 'batch' batch threads.
22.09 16:43:38.315  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(17) in 1 ms:
***
findAll(listOf(defaultEvent.aspId, defaultEvent.eventId, defaultClient.inn, defaultEvent.beginDate, defaultEvent.defaultType, defaultEvent.reasonName), orderBy = listOf(defaultEvent.beginDate), order = DESC, batch = false, deduplicate = true) where {
  JOIN(defaultClient.aspId = 'defaultEvent.aspId')
  (defaultClient_421.inn = any(?1) and
  defaultEvent_430.end_date is null)
}
SELECT defaultEvent_430.asp_id, defaultEvent_430.event_id, defaultClient_421.inn, defaultEvent_430.begin_date, defaultEvent_430.default_type, defaultEvent_430.reason_name
from dm_cib_default.event defaultEvent_430
left join dm_cib_default.client defaultClient_421 on defaultClient_421.asp_id = defaultEvent_430.asp_id
where (defaultClient_421.inn = any(?) and
defaultEvent_430.end_date is null)
order by defaultEvent_430.begin_date desc
***
22.09 16:43:38.360  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(18) in 2 ms:
***
findAll(company, distinctOn = listOf(company.inn), orderBy = listOf(company.inn, company.registrationDate), order = DESC_NULLS_LAST, batch = false, deduplicate = true) fetchFields { listOf(company.opf, company.inn, company.segment, company.riskSegment, company.macroIndustry, company.greName, company.consolidatedGroupName, company.sourceId, company.customerId, company.fullName) } where {
  company.inn = any(?)
  company.category = 'Головная организация'
}
SELECT distinct on(company_41.inn) company_41.opf, company_41.inn, company_41.segment, company_41.risk_segment, company_41.macro_industry, company_41.gre_name, company_41.consolidated_group_name, company_41.source_id, company_41.customer_id, company_41.full_name
from dm_cib_corp_customer.company company_41
where (company_41.inn = any(?) and
company_41.category = 'Головная организация')
order by company_41.inn desc nulls last, company_41.registration_date desc nulls last
***
22.09 16:43:38.405  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(19) in 0 ms:
***
findAll(leRegInfo, batch = false, deduplicate = true) fetchFields { listOf(leRegInfo.inn, leRegInfo.okopfDescr, leRegInfo.baseActivity) } where {
  leRegInfo.inn = any(?)
}
SELECT leRegInfo_446.inn, leRegInfo_446.okopf_descr, leRegInfo_446.base_activity
from dm_cib_bir098.le_reg_info leRegInfo_446
where leRegInfo_446.inn = any(?)
***
22.09 16:43:38.466  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(20) in 1 ms:
***
findAll(listOf(arrearsClientUl.inn, arrearsClientCommon.curOverdueMinDate), orderBy = listOf(arrearsClientCommon.curOverdueMinDate), order = DESC_NULLS_LAST) where {
  JOIN(arrearsClientCommon.customerId = 'arrearsClientUl.customerId')
  (arrearsClientUl_482.inn = any(?1) and
  arrearsClientCommon_514.customer_type = any(array['ИП', 'ЮЛ']) and
  arrearsClientCommon_514.cur_overdue_min_date is not null)
}
SELECT input.index, arrearsClientUl_482.inn, arrearsClientCommon_514.cur_overdue_min_date
from (select generate_series(0, ?) as index, unnest(?) as p0) as input,
dm_cib_arrears.client_ul arrearsClientUl_482
left join dm_cib_arrears.client_common arrearsClientCommon_514 on arrearsClientCommon_514.customer_id = arrearsClientUl_482.customer_id
where (arrearsClientUl_482.inn = any(string_to_array(input.p0, 'ツ')) and
arrearsClientCommon_514.customer_type = any(array['ИП', 'ЮЛ']) and
arrearsClientCommon_514.cur_overdue_min_date is not null)
order by arrearsClientCommon_514.cur_overdue_min_date desc nulls last
***
22.09 16:43:38.493  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(21) in 0 ms:
***
findAll(listOf(arrearsRoleLink.company.inn, arrearsAgreement.agreementDate), orderBy = listOf(arrearsAgreement.agreementDate), order = DESC_NULLS_LAST) where {
  JOIN(arrearsAgreement.agreementId = 'arrearsRoleLink.agreementId'
  arrearsAgreement.ssId = 'arrearsRoleLink.ssId')
  (company_547.inn = any(?1) and
  arrearsRoleLink_538.role = 'заемщик' and
  arrearsAgreement_614.agreement_date is not null)
}
SELECT input.index, company_547.inn, arrearsAgreement_614.agreement_date
from (select generate_series(0, ?) as index, unnest(?) as p0) as input,
dm_cib_arrears.role_link arrearsRoleLink_538
left join dm_cib_arrears.agreement arrearsAgreement_614 on (arrearsAgreement_614.agreement_id = arrearsRoleLink_538.agreement_id and
arrearsAgreement_614.ss_id = arrearsRoleLink_538.ss_id)
left join dm_cib_arrears.client_ul company_547 on arrearsRoleLink_538.customer_id = company_547.customer_id
where (company_547.inn = any(string_to_array(input.p0, 'ツ')) and
arrearsRoleLink_538.role = 'заемщик' and
arrearsAgreement_614.agreement_date is not null)
order by arrearsAgreement_614.agreement_date desc nulls last
***
22.09 16:43:38.522  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(22) in 0 ms:
***
findAll(listOf(company.inn, application.bankCode), orderBy = listOf(application.applicationDate), order = DESC_NULLS_LAST) where {
  JOIN(client.customerId = 'company.customerId'
  application.applicationId = 'client.applicationId')
  (company_41.inn = any(?1) and
  client_1029.role_name = 'Заемщик' and
  application_726.bank_code is not null)
}
SELECT input.index, company_41.inn, application_726.bank_code
from (select generate_series(0, ?) as index, unnest(?) as p0) as input,
dm_cib_corp_customer.company company_41
left join dm_cib_corp_application.customer_role client_1029 on client_1029.customer_id = company_41.customer_id
left join dm_cib_corp_application.application_info application_726 on application_726.application_id = client_1029.application_id
where (company_41.inn = any(string_to_array(input.p0, 'ツ')) and
client_1029.role_name = 'Заемщик' and
application_726.bank_code is not null)
order by application_726.application_date desc nulls last
***
22.09 16:43:38.567  INFO [Dispatcher-worker-2] GeneralInfoLogger                       :  - Fetched client infos in 218 ms.
22.09 16:43:42.265  INFO [ster-poirot_pkap-01] r.s.s.p.s.f.VisitorPersisterFactoryImpl : Generated visitor/persister for FocusMonitoringRecord in 3622 ms.
22.09 16:43:42.532  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 57 ms.
22.09 16:43:42.570  INFO [Dispatcher-worker-3] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(23) in 3 ms:
***
findAll(focusMonitoringRecord, batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.id, focusMonitoringRecord.inputSource, focusMonitoringRecord.processType, focusMonitoringRecord.name, focusMonitoringRecord.inn, focusMonitoringRecord.segment, focusMonitoringRecord.riskSegment, focusMonitoringRecord.macroIndustry, focusMonitoringRecord.gre, focusMonitoringRecord.consGroupName, focusMonitoringRecord.beginDate, focusMonitoringRecord.defaultType, focusMonitoringRecord.clientId, focusMonitoringRecord.epkId, focusMonitoringRecord.clientDivision, focusMonitoringRecord.dateCreate, focusMonitoringRecord.slaByDefault, focusMonitoringRecord.initiatorComment) } where {
  focusMonitoringRecord.id = any(?)
}
SELECT focusMonitoringRecord_233.id, focusMonitoringRecord_233.input_source, focusMonitoringRecord_233.process_type, focusMonitoringRecord_233.name, focusMonitoringRecord_233.inn, focusMonitoringRecord_233.segment, focusMonitoringRecord_233.risk_segment, focusMonitoringRecord_233.macro_industry, focusMonitoringRecord_233.gre, focusMonitoringRecord_233.cons_group_name, focusMonitoringRecord_233.begin_date, focusMonitoringRecord_233.default_type, focusMonitoringRecord_233.client_id, focusMonitoringRecord_233.epk_id, focusMonitoringRecord_233.client_division, focusMonitoringRecord_233.date_create, focusMonitoringRecord_233.sla_by_default, focusMonitoringRecord_233.initiator_comment
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where focusMonitoringRecord_233.id = any(?)
***
22.09 16:43:42.612  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Get focus monitoring records attributes in 46 ms.
22.09 16:43:49.965  INFO [Dispatcher-worker-3] s.p.e.d.q.b.s.j.r.g.GraphLoaderGenerator: Generated GraphLoader in 1220 ms for '[focusMonitoringRecord.id, focusMonitoringRecord.aspId, focusMonitoringRecord.eventId, focusMonitoringRecord.inputSource, focusMonitoringRecord.processType, focusMonitoringRecord.dateCreate, focusMonitoringRecord.dateInitiation, focusMonitoringRecord.dateApproval, focusMonitoringRecord.dateDelete, focusMonitoringRecord.status, focusMonitoringRecord.initiator, focusMonitoringRecord.executor, focusMonitoringRecord.inn, focusMonitoringRecord.name, focusMonitoringRecord.clientId, focusMonitoringRecord.epkId, focusMonitoringRecord.opf, focusMonitoringRecord.defaultType, focusMonitoringRecord.beginDate, focusMonitoringRecord.segment, focusMonitoringRecord.macroIndustry, focusMonitoringRecord.gre, focusMonitoringRecord.consGroupName, focusMonitoringRecord.approver, focusMonitoringRecord.confirmedFraud, focusMonitoringRecord.inProcessFraud, focusMonitoringRecord.dateFraud, focusMonitoringR...
22.09 16:43:49.966  INFO [Dispatcher-worker-3] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(24) in 1228 ms:
***
findAll(focusMonitoringRecord, batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.id, focusMonitoringRecord.aspId, focusMonitoringRecord.eventId, focusMonitoringRecord.inputSource, focusMonitoringRecord.processType, focusMonitoringRecord.dateCreate, focusMonitoringRecord.dateInitiation, focusMonitoringRecord.dateApproval, focusMonitoringRecord.dateDelete, focusMonitoringRecord.status, focusMonitoringRecord.initiator, focusMonitoringRecord.executor, focusMonitoringRecord.inn, focusMonitoringRecord.name, focusMonitoringRecord.clientId, focusMonitoringRecord.epkId, focusMonitoringRecord.opf, focusMonitoringRecord.defaultType, focusMonitoringRecord.beginDate, focusMonitoringRecord.segment, focusMonitoringRecord.macroIndustry, focusMonitoringRecord.gre, focusMonitoringRecord.consGroupName, focusMonitoringRecord.approver, focusMonitoringRecord.confirmedFraud, focusMonitoringRecord.inProcessFraud, focusMonitoringRecord.dateFraud, focusMonitoringRecord.fraudSchemas, focusMonitoringRecord...
  focusMonitoringRecord.id = any(?)
}
SELECT focusMonitoringRecord_233.id, focusMonitoringRecord_233.asp_id, focusMonitoringRecord_233.event_id, focusMonitoringRecord_233.input_source, focusMonitoringRecord_233.process_type, focusMonitoringRecord_233.date_create, focusMonitoringRecord_233.date_initiation, focusMonitoringRecord_233.date_approval, focusMonitoringRecord_233.date_delete, focusMonitoringRecord_233.status, focusMonitoringRecord_233.initiator, focusMonitoringRecord_233.executor, focusMonitoringRecord_233.inn, focusMonitoringRecord_233.name, focusMonitoringRecord_233.client_id, focusMonitoringRecord_233.epk_id, focusMonitoringRecord_233.opf, focusMonitoringRecord_233.default_type, focusMonitoringRecord_233.begin_date, focusMonitoringRecord_233.segment, focusMonitoringRecord_233.macro_industry, focusMonitoringRecord_233.gre, focusMonitoringRecord_233.cons_group_name, focusMonitoringRecord_233.approver, focusMonitoringRecord_233.confirmed_fraud, focusMonitoringRecord_233.in_process_fraud, focusMonitoringRecord_233.date_fraud, focusMonit...
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where focusMonitoringRecord_233.id = any(?)
***
22.09 16:43:50.166  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring records by ids in 1428 ms.
22.09 16:43:50.605  INFO [ster-poirot_pkap-01] r.s.s.p.s.f.VisitorPersisterFactoryImpl : Generated visitor/persister for FakeReport in 437 ms.
22.09 16:43:50.779  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(25) in 0 ms:
***
findAll(company, distinctOn = listOf(company.inn), orderBy = listOf(company.inn, company.registrationDate), order = DESC_NULLS_LAST, limit = 1, batch = false, deduplicate = true) fetchFields { listOf(company.customerId, company.inn, company.fullName, company.registrationCountry, company.segment, company.opf, company.industry, company.sector, company.macroIndustry, company.subIndustry) } where {
  company.inn = ?
  company.category = 'Головная организация'
}
SELECT distinct on(company_41.inn) company_41.customer_id, company_41.inn, company_41.full_name, company_41.registration_country, company_41.segment, company_41.opf, company_41.industry, company_41.sector, company_41.macro_industry, company_41.sub_industry
from dm_cib_corp_customer.company company_41
where (company_41.inn = ? and
company_41.category = 'Головная организация')
order by company_41.inn desc nulls last, company_41.registration_date desc nulls last
limit 1
***
22.09 16:43:50.821  INFO [Dispatcher-worker-2] r.sber.poirot.dpa.client.HttpDpaClient  : Send req to dis-pro-adapter taskId=[616001, FOCUS_MONITORING], processType={}
22.09 16:43:52.222  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 54 ms.
22.09 16:43:57.275  INFO [Dispatcher-worker-3] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(26) in 0 ms:
***
findAll(focusMonitoringRecord, orderBy = listOf(focusMonitoringRecord.dateInitiation), batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.id) } where {
  focusMonitoringRecord.status = any(?)
  focusMonitoringRecord.approver is null or focusMonitoringRecord.approver = ? or focusMonitoringRecord.executor = ?
  focusMonitoringRecord.dateInitiation is null or focusMonitoringRecord.dateInitiation >= ?
  focusMonitoringRecord.dateInitiation <= ?
}
SELECT focusMonitoringRecord_233.id
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where (focusMonitoringRecord_233.status = any(?) and
(focusMonitoringRecord_233.approver is null or
focusMonitoringRecord_233.approver = ? or
focusMonitoringRecord_233.executor = ?) and
(focusMonitoringRecord_233.date_initiation is null or
(focusMonitoringRecord_233.date_initiation >= ? and
focusMonitoringRecord_233.date_initiation <= ?)))
order by focusMonitoringRecord_233.date_initiation asc
***
22.09 16:43:57.330  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 55 ms.
22.09 16:43:57.331  INFO [Dispatcher-worker-3] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(27) in 0 ms:
***
findAll(focusMonitoringRecord, batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.id, focusMonitoringRecord.processType, focusMonitoringRecord.dateInitiation, focusMonitoringRecord.status, focusMonitoringRecord.clientId, focusMonitoringRecord.opf, focusMonitoringRecord.name, focusMonitoringRecord.inn, focusMonitoringRecord.segment, focusMonitoringRecord.riskSegment, focusMonitoringRecord.macroIndustry, focusMonitoringRecord.gre, focusMonitoringRecord.consGroupName, focusMonitoringRecord.clientDivision, focusMonitoringRecord.defaultType, focusMonitoringRecord.beginDate, focusMonitoringRecord.initiator, focusMonitoringRecord.slaByDefault, focusMonitoringRecord.initiatorComment) } where {
  focusMonitoringRecord.id = any(?)
}
SELECT focusMonitoringRecord_233.id, focusMonitoringRecord_233.process_type, focusMonitoringRecord_233.date_initiation, focusMonitoringRecord_233.status, focusMonitoringRecord_233.client_id, focusMonitoringRecord_233.opf, focusMonitoringRecord_233.name, focusMonitoringRecord_233.inn, focusMonitoringRecord_233.segment, focusMonitoringRecord_233.risk_segment, focusMonitoringRecord_233.macro_industry, focusMonitoringRecord_233.gre, focusMonitoringRecord_233.cons_group_name, focusMonitoringRecord_233.client_division, focusMonitoringRecord_233.default_type, focusMonitoringRecord_233.begin_date, focusMonitoringRecord_233.initiator, focusMonitoringRecord_233.sla_by_default, focusMonitoringRecord_233.initiator_comment
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where focusMonitoringRecord_233.id = any(?)
***
22.09 16:43:57.368  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Get focus monitoring records attributes in 37 ms.
22.09 16:44:00.590  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(28) in 1 ms:
***
findAll(focusMonitoringRecord, limit = 1, batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.id, focusMonitoringRecord.aspId, focusMonitoringRecord.eventId, focusMonitoringRecord.inputSource, focusMonitoringRecord.processType, focusMonitoringRecord.dateCreate, focusMonitoringRecord.dateInitiation, focusMonitoringRecord.dateApproval, focusMonitoringRecord.dateDelete, focusMonitoringRecord.status, focusMonitoringRecord.initiator, focusMonitoringRecord.executor, focusMonitoringRecord.inn, focusMonitoringRecord.name, focusMonitoringRecord.clientId, focusMonitoringRecord.epkId, focusMonitoringRecord.opf, focusMonitoringRecord.defaultType, focusMonitoringRecord.beginDate, focusMonitoringRecord.segment, focusMonitoringRecord.macroIndustry, focusMonitoringRecord.gre, focusMonitoringRecord.consGroupName, focusMonitoringRecord.approver, focusMonitoringRecord.confirmedFraud, focusMonitoringRecord.inProcessFraud, focusMonitoringRecord.dateFraud, focusMonitoringRecord.fraudSchemas, focusMonit...
  focusMonitoringRecord.id = ?
  focusMonitoringRecord.status = any(?)
}
SELECT focusMonitoringRecord_233.id, focusMonitoringRecord_233.asp_id, focusMonitoringRecord_233.event_id, focusMonitoringRecord_233.input_source, focusMonitoringRecord_233.process_type, focusMonitoringRecord_233.date_create, focusMonitoringRecord_233.date_initiation, focusMonitoringRecord_233.date_approval, focusMonitoringRecord_233.date_delete, focusMonitoringRecord_233.status, focusMonitoringRecord_233.initiator, focusMonitoringRecord_233.executor, focusMonitoringRecord_233.inn, focusMonitoringRecord_233.name, focusMonitoringRecord_233.client_id, focusMonitoringRecord_233.epk_id, focusMonitoringRecord_233.opf, focusMonitoringRecord_233.default_type, focusMonitoringRecord_233.begin_date, focusMonitoringRecord_233.segment, focusMonitoringRecord_233.macro_industry, focusMonitoringRecord_233.gre, focusMonitoringRecord_233.cons_group_name, focusMonitoringRecord_233.approver, focusMonitoringRecord_233.confirmed_fraud, focusMonitoringRecord_233.in_process_fraud, focusMonitoringRecord_233.date_fraud, focusMonit...
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where (focusMonitoringRecord_233.id = ? and
focusMonitoringRecord_233.status = any(?))
limit 1
***
22.09 16:44:00.740  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 152 ms.
22.09 16:44:01.286  INFO [Dispatcher-worker-2] s.p.e.d.q.b.s.j.r.g.GraphLoaderGenerator: Generated GraphLoader in 516 ms for '[suspiciousClient.id, suspiciousClient.taskId, suspiciousClient.processType, suspiciousClient.fraudScheme, suspiciousClient.personalData.id, suspiciousClient.personalData.clientType, suspiciousClient.personalData.inn, suspiciousClient.personalData.name, suspiciousClient.personalData.firstName, suspiciousClient.personalData.secondName, suspiciousClient.personalData.lastName, suspiciousClient.personalData.birthDate]'
22.09 16:44:01.287  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(29) in 543 ms:
***
findAll(suspiciousClient, batch = false, deduplicate = true) fetchFields { listOf(suspiciousClient.id, suspiciousClient.taskId, suspiciousClient.processType, suspiciousClient.fraudScheme, suspiciousClient.personalData.id, suspiciousClient.personalData.clientType, suspiciousClient.personalData.inn, suspiciousClient.personalData.name, suspiciousClient.personalData.firstName, suspiciousClient.personalData.secondName, suspiciousClient.personalData.lastName, suspiciousClient.personalData.birthDate) } where {
  suspiciousClient.taskId = ?
  suspiciousClient.processType = ?
}
SELECT suspiciousClient_1229.id, suspiciousClient_1229.task_id, suspiciousClient_1229.process_type, suspiciousClient_1229.fraud_scheme, suspiciousClient_1229.personal_data_id
from re_suspicions.suspicious_client suspiciousClient_1229
where (suspiciousClient_1229.task_id = ? and
suspiciousClient_1229.process_type = ?)
***
22.09 16:44:01.392  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(30) in 0 ms:
***
findAll(disReassignmentEvent, orderBy = listOf(disReassignmentEvent.requestTime), order = DESC, limit = 1, batch = false, deduplicate = true) fetchFields { listOf(disReassignmentEvent.id, disReassignmentEvent.processType, disReassignmentEvent.taskId, disReassignmentEvent.previousExecutor, disReassignmentEvent.mode, disReassignmentEvent.reasonCode, disReassignmentEvent.newExecutor, disReassignmentEvent.requestTime) } where {
  disReassignmentEvent.processType = ?
  disReassignmentEvent.taskId = ?
}
SELECT disReassignmentEvent_1243.id, disReassignmentEvent_1243.process_type, disReassignmentEvent_1243.task_id, disReassignmentEvent_1243.previous_executor, disReassignmentEvent_1243.mode, disReassignmentEvent_1243.reason_code, disReassignmentEvent_1243.new_executor, disReassignmentEvent_1243.request_time
from dis.reassignment_event disReassignmentEvent_1243
where (disReassignmentEvent_1243.process_type = ? and
disReassignmentEvent_1243.task_id = ?)
order by disReassignmentEvent_1243.request_time desc
limit 1
***
22.09 16:44:01.470  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(31) in 1 ms:
***
findAll(disSla, orderBy = listOf(disSla.updateTime), order = DESC, limit = 1, batch = false, deduplicate = true) fetchFields { listOf(disSla.id, disSla.processType, disSla.taskId, disSla.sla, disSla.changeReason, disSla.updateTime) } where {
  disSla.processType = 'FOCUS_MONITORING'
  disSla.taskId = ?
}
SELECT disSla_1252.id, disSla_1252.process_type, disSla_1252.task_id, disSla_1252.sla, disSla_1252.change_reason, disSla_1252.update_time
from dis.sla disSla_1252
where (disSla_1252.process_type = 'FOCUS_MONITORING' and
disSla_1252.task_id = ?)
order by disSla_1252.update_time desc
limit 1
***
22.09 16:44:01.777  INFO [Dispatcher-worker-2] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(32) in 1 ms:
***
findAll(userFileInfo, batch = false, deduplicate = true) fetchFields { listOf(userFileInfo.processRequestUid, userFileInfo.taskId) } where {
  userFileInfo.process = ?
  userFileInfo.status = any(?)
  userFileInfo.taskId = ?
}
SELECT userFileInfo_1259.process_request_uid, userFileInfo_1259.task_id
from frontback.user_file_info userFileInfo_1259
where (userFileInfo_1259.process = ? and
userFileInfo_1259.status = any(?) and
userFileInfo_1259.task_id = ?)
***
22.09 16:44:18.882  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 52 ms.
22.09 16:44:18.918  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Get focus monitoring records attributes in 35 ms.
22.09 16:44:20.628  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 130 ms.
22.09 16:44:21.956  INFO [Dispatcher-worker-3] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(33) in 0 ms:
***
findAll(focusMonitoringRecord, limit = 1, batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.id, focusMonitoringRecord.aspId, focusMonitoringRecord.eventId, focusMonitoringRecord.inputSource, focusMonitoringRecord.processType, focusMonitoringRecord.dateCreate, focusMonitoringRecord.dateInitiation, focusMonitoringRecord.dateApproval, focusMonitoringRecord.dateDelete, focusMonitoringRecord.status, focusMonitoringRecord.initiator, focusMonitoringRecord.executor, focusMonitoringRecord.inn, focusMonitoringRecord.name, focusMonitoringRecord.clientId, focusMonitoringRecord.epkId, focusMonitoringRecord.opf, focusMonitoringRecord.defaultType, focusMonitoringRecord.beginDate, focusMonitoringRecord.segment, focusMonitoringRecord.macroIndustry, focusMonitoringRecord.gre, focusMonitoringRecord.consGroupName, focusMonitoringRecord.approver, focusMonitoringRecord.confirmedFraud, focusMonitoringRecord.inProcessFraud, focusMonitoringRecord.dateFraud, focusMonitoringRecord.fraudSchemas, focusMonit...
  focusMonitoringRecord.id = ?
}
SELECT focusMonitoringRecord_233.id, focusMonitoringRecord_233.asp_id, focusMonitoringRecord_233.event_id, focusMonitoringRecord_233.input_source, focusMonitoringRecord_233.process_type, focusMonitoringRecord_233.date_create, focusMonitoringRecord_233.date_initiation, focusMonitoringRecord_233.date_approval, focusMonitoringRecord_233.date_delete, focusMonitoringRecord_233.status, focusMonitoringRecord_233.initiator, focusMonitoringRecord_233.executor, focusMonitoringRecord_233.inn, focusMonitoringRecord_233.name, focusMonitoringRecord_233.client_id, focusMonitoringRecord_233.epk_id, focusMonitoringRecord_233.opf, focusMonitoringRecord_233.default_type, focusMonitoringRecord_233.begin_date, focusMonitoringRecord_233.segment, focusMonitoringRecord_233.macro_industry, focusMonitoringRecord_233.gre, focusMonitoringRecord_233.cons_group_name, focusMonitoringRecord_233.approver, focusMonitoringRecord_233.confirmed_fraud, focusMonitoringRecord_233.in_process_fraud, focusMonitoringRecord_233.date_fraud, focusMonit...
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where focusMonitoringRecord_233.id = ?
limit 1
***
22.09 16:44:22.081  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id in 125 ms.
22.09 16:44:22.083  INFO [Dispatcher-worker-3] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(34) in 1 ms:
***
findAll(focusMonitoringRecord, limit = 1, batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.id, focusMonitoringRecord.aspId, focusMonitoringRecord.eventId, focusMonitoringRecord.inputSource, focusMonitoringRecord.processType, focusMonitoringRecord.dateCreate, focusMonitoringRecord.dateInitiation, focusMonitoringRecord.dateApproval, focusMonitoringRecord.dateDelete, focusMonitoringRecord.status, focusMonitoringRecord.initiator, focusMonitoringRecord.executor, focusMonitoringRecord.inn, focusMonitoringRecord.name, focusMonitoringRecord.clientId, focusMonitoringRecord.epkId, focusMonitoringRecord.opf, focusMonitoringRecord.defaultType, focusMonitoringRecord.beginDate, focusMonitoringRecord.segment, focusMonitoringRecord.macroIndustry, focusMonitoringRecord.gre, focusMonitoringRecord.consGroupName, focusMonitoringRecord.approver, focusMonitoringRecord.confirmedFraud, focusMonitoringRecord.inProcessFraud, focusMonitoringRecord.dateFraud, focusMonitoringRecord.fraudSchemas, focusMonit...
  focusMonitoringRecord.id = ?
  focusMonitoringRecord.executor = ?
  focusMonitoringRecord.status = any(?)
}
SELECT focusMonitoringRecord_233.id, focusMonitoringRecord_233.asp_id, focusMonitoringRecord_233.event_id, focusMonitoringRecord_233.input_source, focusMonitoringRecord_233.process_type, focusMonitoringRecord_233.date_create, focusMonitoringRecord_233.date_initiation, focusMonitoringRecord_233.date_approval, focusMonitoringRecord_233.date_delete, focusMonitoringRecord_233.status, focusMonitoringRecord_233.initiator, focusMonitoringRecord_233.executor, focusMonitoringRecord_233.inn, focusMonitoringRecord_233.name, focusMonitoringRecord_233.client_id, focusMonitoringRecord_233.epk_id, focusMonitoringRecord_233.opf, focusMonitoringRecord_233.default_type, focusMonitoringRecord_233.begin_date, focusMonitoringRecord_233.segment, focusMonitoringRecord_233.macro_industry, focusMonitoringRecord_233.gre, focusMonitoringRecord_233.cons_group_name, focusMonitoringRecord_233.approver, focusMonitoringRecord_233.confirmed_fraud, focusMonitoringRecord_233.in_process_fraud, focusMonitoringRecord_233.date_fraud, focusMonit...
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where (focusMonitoringRecord_233.id = ? and
focusMonitoringRecord_233.executor = ? and
focusMonitoringRecord_233.status = any(?))
limit 1
***
22.09 16:44:22.191  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id, statuses and login in 109 ms.
22.09 16:44:22.234  INFO [           trans-01] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(35) in 0 ms:
***
existsAny(disRecord, limit = 1, batch = false) where {
  disRecord.taskId = ?
}
SELECT 0
from dis.dis_record disRecord_1266
where disRecord_1266.task_id = ?
limit 1
***
22.09 16:44:22.484  INFO [           trans-01] r.sber.poirot.dpa.client.HttpDpaClient  : Send notify req to dis-pro-adapter taskId=[616001, IN_PROGRESS, FOCUS_MONITORING], taskStatus={}, processType={}
22.09 16:44:22.736  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 102 ms.
22.09 16:44:58.333  INFO [Dispatcher-worker-3] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(36) in 0 ms:
***
findAll(focusMonitoringRecord, orderBy = listOf(focusMonitoringRecord.dateInitiation), batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.id) } where {
  focusMonitoringRecord.status = any(array[3, 4, 5, 6, 7, 2, 8, 9, 10])
  focusMonitoringRecord.dateInitiation is null or focusMonitoringRecord.dateInitiation >= ?
  focusMonitoringRecord.dateInitiation <= ?
}
SELECT focusMonitoringRecord_233.id
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where (focusMonitoringRecord_233.status = any(array[3, 4, 5, 6, 7, 2, 8, 9, 10]) and
(focusMonitoringRecord_233.date_initiation is null or
(focusMonitoringRecord_233.date_initiation >= ? and
focusMonitoringRecord_233.date_initiation <= ?)))
order by focusMonitoringRecord_233.date_initiation asc
***
22.09 16:44:58.489  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 157 ms.
22.09 16:44:58.597  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Get focus monitoring records attributes in 101 ms.
22.09 16:45:00.224  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 119 ms.
22.09 16:45:03.484  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 117 ms.
22.09 16:45:09.473  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 116 ms.
22.09 16:45:24.807  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 119 ms.
22.09 16:45:24.842  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 153 ms.
22.09 16:45:24.893  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Get focus monitoring records attributes in 51 ms.
22.09 16:45:29.417  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 120 ms.
22.09 16:45:47.001  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id, statuses and login in 126 ms.
22.09 16:45:47.004  INFO [Dispatcher-worker-1] r.s.p.s.manage.BaseSuspicionManager     : No suspicion entities passed taskId: 609101, process: FocusMonitoring
22.09 16:45:47.065  INFO [      batch-gateway] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(37) in 47 ms:
***
findAll(listOf(suspiciousClient.id, suspiciousClient.taskId, suspiciousClient.processType, suspiciousClient.fraudScheme, suspiciousClient.personalData.id)) where {
  suspiciousClient.taskId = ?
  suspiciousClient.processType = ?
}
SELECT input.index, suspiciousClient_1229.id, suspiciousClient_1229.task_id, suspiciousClient_1229.process_type, suspiciousClient_1229.fraud_scheme, personalData_1231.id
from (select generate_series(0, ?) as index, unnest(?) as p0, unnest(?) as p1) as input,
re_suspicions.suspicious_client suspiciousClient_1229
left join re_suspicions.personal_data personalData_1231 on suspiciousClient_1229.personal_data_id = personalData_1231.id
where (suspiciousClient_1229.task_id = input.p0 and
suspiciousClient_1229.process_type = input.p1)
***
22.09 16:45:47.492  INFO [sactions-suspend-02] s.p.e.d.q.b.s.j.r.g.GraphLoaderGenerator: Generated GraphLoader in 381 ms for '[focusMonitoringRecord.fakeReport.affectedDates.id, focusMonitoringRecord.fakeReport.affectedDates.fakeReportId, focusMonitoringRecord.fakeReport.affectedDates.affectedDate]'
22.09 16:45:47.492  INFO [sactions-suspend-02] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(38) in 383 ms:
***
findAll(focusMonitoringRecord, limit = 1, batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.fakeReport.affectedDates.id, focusMonitoringRecord.fakeReport.affectedDates.fakeReportId, focusMonitoringRecord.fakeReport.affectedDates.affectedDate) } where {
  focusMonitoringRecord.id = ?
}
SELECT focusMonitoringRecord_233.id, focusMonitoringRecord_233.fake_report_id
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where focusMonitoringRecord_233.id = ?
limit 1
***
22.09 16:45:48.168  INFO [sactions-suspend-02] s.p.e.d.q.b.s.j.r.g.GraphLoaderGenerator: Generated GraphLoader in 354 ms for '[focusMonitoringRecord.monitoringProcessFraudSchemes.id, focusMonitoringRecord.monitoringProcessFraudSchemes.focusMonitoringRecordId, focusMonitoringRecord.monitoringProcessFraudSchemes.fraudSchemeId, focusMonitoringRecord.monitoringProcessFraudSchemes.shortComment, focusMonitoringRecord.monitoringProcessFraudSchemes.fullComment]'
22.09 16:45:48.168  INFO [sactions-suspend-02] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(39) in 355 ms:
***
findAll(focusMonitoringRecord, limit = 1, batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.monitoringProcessFraudSchemes.id, focusMonitoringRecord.monitoringProcessFraudSchemes.focusMonitoringRecordId, focusMonitoringRecord.monitoringProcessFraudSchemes.fraudSchemeId, focusMonitoringRecord.monitoringProcessFraudSchemes.shortComment, focusMonitoringRecord.monitoringProcessFraudSchemes.fullComment) } where {
  focusMonitoringRecord.id = ?
}
SELECT focusMonitoringRecord_233.id
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where focusMonitoringRecord_233.id = ?
limit 1
***
22.09 16:45:48.589  INFO [sactions-suspend-02] r.s.s.p.s.f.VisitorPersisterFactoryImpl : Generated visitor/persister for CapitalOutflow in 384 ms.
22.09 16:45:49.203  INFO [sactions-suspend-02] r.s.s.p.s.f.VisitorPersisterFactoryImpl : Generated visitor/persister for Bankruptcy in 521 ms.
22.09 16:45:49.486  INFO [Dispatcher-worker-3] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 101 ms.
22.09 16:46:15.844  INFO [         refresh-03] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'UserInfoProviderImpl.userInfo: [BASKET_FOCUS_MONITORING, STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM, STATUS_AGREEMENT_FM, FM_FILE_EXECUTION, REGISTRY_FM, REGISTRY_FM_EMPLOYEE, EDIT_AGREED_FM, INITIATION_FOCUS_MONITORING, FM_AUTOLOAD_RECORDS, DELETE_TASK_FM]'. Fetched 82 items in 0 sec. Size: 0 KB. Versions: 1 -> 2.
22.09 16:46:18.351  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id, statuses and login in 116 ms.
22.09 16:46:18.351  INFO [Dispatcher-worker-2] r.s.p.s.manage.BaseSuspicionManager     : No suspicion entities passed taskId: 616001, process: FocusMonitoring
22.09 16:46:18.704  INFO [sactions-suspend-02] r.s.s.p.s.f.VisitorPersisterFactoryImpl : Generated visitor/persister for MonitoringProcessFraudScheme in 194 ms.
22.09 16:46:18.986  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 107 ms.
22.09 16:47:30.339  INFO [         refresh-03] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'UserInfoProviderImpl.userInfo: [STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM]'. Fetched 10 items in 0 sec. Size: 0 KB. Versions: 1 -> 2.
22.09 16:48:48.528  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id, statuses and login in 118 ms.
22.09 16:48:48.528  INFO [Dispatcher-worker-2] r.s.p.s.manage.BaseSuspicionManager     : No suspicion entities passed taskId: 616001, process: FocusMonitoring
22.09 16:48:49.274  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 96 ms.
22.09 16:48:58.584  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id, statuses and login in 110 ms.
22.09 16:48:58.585  INFO [Dispatcher-worker-1] r.s.p.s.manage.BaseSuspicionManager     : No suspicion entities passed taskId: 616001, process: FocusMonitoring
22.09 16:48:58.967  INFO [Dispatcher-worker-1] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(40) in 0 ms:
***
findAll(focusMonitoringRecord, batch = false, deduplicate = true) fetchFields { listOf(focusMonitoringRecord.id, focusMonitoringRecord.dateInitiation, focusMonitoringRecord.dateCreate, focusMonitoringRecord.name, focusMonitoringRecord.inn, focusMonitoringRecord.status) } where {
  focusMonitoringRecord.status = ?
  focusMonitoringRecord.executor = ? or focusMonitoringRecord.status = ?
  focusMonitoringRecord.executor = ? or focusMonitoringRecord.status = ?
  focusMonitoringRecord.executor = ? or focusMonitoringRecord.status = ?
  focusMonitoringRecord.executor = ? or focusMonitoringRecord.status = ?
  focusMonitoringRecord.approver is null or focusMonitoringRecord.approver = ?
  focusMonitoringRecord.dateInitiation >= ?
  focusMonitoringRecord.dateInitiation < ?
}
SELECT focusMonitoringRecord_233.id, focusMonitoringRecord_233.date_initiation, focusMonitoringRecord_233.date_create, focusMonitoringRecord_233.name, focusMonitoringRecord_233.inn, focusMonitoringRecord_233.status
from focus_monitoring.focus_monitoring_record focusMonitoringRecord_233
where (((focusMonitoringRecord_233.status = ? and
focusMonitoringRecord_233.executor = ?) or
(focusMonitoringRecord_233.status = ? and
focusMonitoringRecord_233.executor = ?) or
(focusMonitoringRecord_233.status = ? and
focusMonitoringRecord_233.executor = ?) or
(focusMonitoringRecord_233.status = ? and
focusMonitoringRecord_233.executor = ?) or
(focusMonitoringRecord_233.status = ? and
(focusMonitoringRecord_233.approver is null or
focusMonitoringRecord_233.approver = ?))) and
focusMonitoringRecord_233.date_initiation >= ? and
focusMonitoringRecord_233.date_initiation < ?)
***
22.09 16:48:59.065  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 142 ms.
22.09 16:48:59.071  INFO [        small-00-01] r.s.p.e.d.q.b.s.jdbc.JdbcSelectFactory  : GENERATED DSL SQL(41) in 2 ms:
***
findAll(disSla, orderBy = listOf(disSla.updateTime), order = DESC, limit = 2) fetchFields { listOf(disSla.id, disSla.processType, disSla.taskId, disSla.sla, disSla.changeReason, disSla.updateTime) } where {
  disSla.processType = 'FOCUS_MONITORING'
  disSla.taskId = ?
}
SELECT input.index, main.*
from (select generate_series(0, ?) as index, unnest(?) as p0) as input
join lateral (
select disSla_1252.id, disSla_1252.process_type, disSla_1252.task_id, disSla_1252.sla, disSla_1252.change_reason, disSla_1252.update_time
from dis.sla disSla_1252
where (disSla_1252.process_type = 'FOCUS_MONITORING' and
disSla_1252.task_id = input.p0)
order by disSla_1252.update_time desc
limit 2
) main on true
***
22.09 16:48:59.083  INFO [Dispatcher-worker-2] r.s.p.f.u.c.dao.DslUnifiedRecordsDao    : Found unified records in 112 ms.
22.09 16:50:27.081  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 119 ms.
22.09 16:50:27.444  INFO [           trans-02] r.sber.poirot.dpa.client.HttpDpaClient  : Send notify req to dis-pro-adapter taskId=[616001, DONE, FOCUS_MONITORING], taskStatus={}, processType={}
22.09 16:50:27.514 ERROR [Dispatcher-worker-2] a.w.r.e.AbstractErrorWebExceptionHandler: [b05a4b66-314]  500 Server Error for HTTP POST "/api/agreement/agree/616001"

java.util.NoSuchElementException: Collection contains no element matching the predicate.
	at ru.sber.poirot.focus.stages.FmFraudManager.fraudRecords(FmFraudManager.kt:172)
	Suppressed: reactor.core.publisher.FluxOnAssembly$OnAssemblyException:
Error has been observed at the following site(s):
	*__checkpoint ⇢ Handler ru.sber.poirot.focus.stages.agreement.AgreementController#agree(long, Continuation) [DispatcherHandler]
	*__checkpoint ⇢ SecurityConfig$$Lambda$1307/0x0000000801ae60c0 [DefaultWebFilterChain]
	*__checkpoint ⇢ AuthorizationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ExceptionTranslationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ LogoutWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ServerRequestCacheWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ SecurityContextServerWebExchangeWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ AuthenticationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ReactorContextWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ HttpHeaderWriterWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ServerWebExchangeReactorContextWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ org.springframework.security.web.server.WebFilterChainProxy [DefaultWebFilterChain]
	*__checkpoint ⇢ HTTP POST "/api/agreement/agree/616001" [ExceptionHandlingWebHandler]
Original Stack Trace:
		at ru.sber.poirot.focus.stages.FmFraudManager.fraudRecords(FmFraudManager.kt:172)
		at ru.sber.poirot.focus.stages.FmFraudManager.addFrauds$suspendImpl(FmFraudManager.kt:30)
		at ru.sber.poirot.focus.stages.FmFraudManager.addFrauds(FmFraudManager.kt)
		at ru.sber.poirot.fraud.client.FraudManager.addFrauds$suspendImpl(FraudManager.kt:4)
		at ru.sber.poirot.fraud.client.FraudManager.addFrauds(FraudManager.kt)
		at ru.sber.poirot.focus.stages.agreement.AgreementServiceImpl$agree$2.invokeSuspend(AgreementServiceImpl.kt:39)
		at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
		at kotlinx.coroutines.DispatchedTask.run(DispatchedTask.kt:104)
		at kotlinx.coroutines.EventLoopImplBase.processNextEvent(EventLoop.common.kt:277)
		at kotlinx.coroutines.BlockingCoroutine.joinBlocking(Builders.kt:95)
		at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking(Builders.kt:69)
		at kotlinx.coroutines.BuildersKt.runBlocking(Unknown Source)
		at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking$default(Builders.kt:48)
		at kotlinx.coroutines.BuildersKt.runBlocking$default(Unknown Source)
		at ru.sber.poirot.utils.TransactionalUtilsKt$transactionalWithReactorContext$$inlined$transactional$1$1.doInTransaction(Transactions.kt:26)
		at org.springframework.transaction.support.TransactionTemplate.execute(TransactionTemplate.java:140)
		at ru.sber.poirot.utils.TransactionalUtilsKt$transactionalWithReactorContext$$inlined$transactional$1.invokeSuspend(Transactions.kt:25)
		at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
		at kotlinx.coroutines.DispatchedTask.run(DispatchedTask.kt:104)
		at java.base/java.util.concurrent.ForkJoinTask$RunnableExecuteAction.exec(ForkJoinTask.java:1395)
		at java.base/java.util.concurrent.ForkJoinTask.doExec(ForkJoinTask.java:373)
		at java.base/java.util.concurrent.ForkJoinPool$WorkQueue.topLevelExec(ForkJoinPool.java:1182)
		at java.base/java.util.concurrent.ForkJoinPool.scan(ForkJoinPool.java:1655)
		at java.base/java.util.concurrent.ForkJoinPool.runWorker(ForkJoinPool.java:1622)
		at java.base/java.util.concurrent.ForkJoinWorkerThread.run(ForkJoinWorkerThread.java:165)

22.09 16:51:12.135  INFO [         refresh-08] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'UserInfoProviderImpl.userInfo: [STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM]'. Fetched 10 items in 0 sec. Size: 0 KB. Versions: 2 -> 3.
22.09 16:51:24.339  INFO [         refresh-08] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'UserInfoProviderImpl.userInfo: [BASKET_FOCUS_MONITORING, STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM, STATUS_AGREEMENT_FM, FM_FILE_EXECUTION, REGISTRY_FM, REGISTRY_FM_EMPLOYEE, EDIT_AGREED_FM, INITIATION_FOCUS_MONITORING, FM_AUTOLOAD_RECORDS, DELETE_TASK_FM]'. Fetched 82 items in 0 sec. Size: 0 KB. Versions: 2 -> 3.
22.09 16:52:29.471  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 123 ms.
22.09 16:52:34.200  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 114 ms.
22.09 16:52:34.552  INFO [           trans-03] r.sber.poirot.dpa.client.HttpDpaClient  : Send notify req to dis-pro-adapter taskId=[616001, DONE, FOCUS_MONITORING], taskStatus={}, processType={}
22.09 16:52:34.611 ERROR [Dispatcher-worker-1] a.w.r.e.AbstractErrorWebExceptionHandler: [c3c0a757-392]  500 Server Error for HTTP POST "/api/agreement/agree/616001"

java.util.NoSuchElementException: Collection contains no element matching the predicate.
	at ru.sber.poirot.focus.stages.FmFraudManager.fraudRecords(FmFraudManager.kt:172)
	Suppressed: reactor.core.publisher.FluxOnAssembly$OnAssemblyException:
Error has been observed at the following site(s):
	*__checkpoint ⇢ Handler ru.sber.poirot.focus.stages.agreement.AgreementController#agree(long, Continuation) [DispatcherHandler]
	*__checkpoint ⇢ SecurityConfig$$Lambda$1307/0x0000000801ae60c0 [DefaultWebFilterChain]
	*__checkpoint ⇢ AuthorizationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ExceptionTranslationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ LogoutWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ServerRequestCacheWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ SecurityContextServerWebExchangeWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ AuthenticationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ReactorContextWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ HttpHeaderWriterWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ServerWebExchangeReactorContextWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ org.springframework.security.web.server.WebFilterChainProxy [DefaultWebFilterChain]
	*__checkpoint ⇢ HTTP POST "/api/agreement/agree/616001" [ExceptionHandlingWebHandler]
Original Stack Trace:
		at ru.sber.poirot.focus.stages.FmFraudManager.fraudRecords(FmFraudManager.kt:172)
		at ru.sber.poirot.focus.stages.FmFraudManager.addFrauds$suspendImpl(FmFraudManager.kt:30)
		at ru.sber.poirot.focus.stages.FmFraudManager.addFrauds(FmFraudManager.kt)
		at ru.sber.poirot.fraud.client.FraudManager.addFrauds$suspendImpl(FraudManager.kt:4)
		at ru.sber.poirot.fraud.client.FraudManager.addFrauds(FraudManager.kt)
		at ru.sber.poirot.focus.stages.agreement.AgreementServiceImpl$agree$2.invokeSuspend(AgreementServiceImpl.kt:39)
		at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
		at kotlinx.coroutines.DispatchedTask.run(DispatchedTask.kt:104)
		at kotlinx.coroutines.EventLoopImplBase.processNextEvent(EventLoop.common.kt:277)
		at kotlinx.coroutines.BlockingCoroutine.joinBlocking(Builders.kt:95)
		at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking(Builders.kt:69)
		at kotlinx.coroutines.BuildersKt.runBlocking(Unknown Source)
		at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking$default(Builders.kt:48)
		at kotlinx.coroutines.BuildersKt.runBlocking$default(Unknown Source)
		at ru.sber.poirot.utils.TransactionalUtilsKt$transactionalWithReactorContext$$inlined$transactional$1$1.doInTransaction(Transactions.kt:26)
		at org.springframework.transaction.support.TransactionTemplate.execute(TransactionTemplate.java:140)
		at ru.sber.poirot.utils.TransactionalUtilsKt$transactionalWithReactorContext$$inlined$transactional$1.invokeSuspend(Transactions.kt:25)
		at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
		at kotlinx.coroutines.DispatchedTask.run(DispatchedTask.kt:104)
		at java.base/java.util.concurrent.ForkJoinTask$RunnableExecuteAction.exec(ForkJoinTask.java:1395)
		at java.base/java.util.concurrent.ForkJoinTask.doExec(ForkJoinTask.java:373)
		at java.base/java.util.concurrent.ForkJoinPool$WorkQueue.topLevelExec(ForkJoinPool.java:1182)
		at java.base/java.util.concurrent.ForkJoinPool.scan(ForkJoinPool.java:1655)
		at java.base/java.util.concurrent.ForkJoinPool.runWorker(ForkJoinPool.java:1622)
		at java.base/java.util.concurrent.ForkJoinWorkerThread.run(ForkJoinWorkerThread.java:165)

22.09 16:54:45.657  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 110 ms.
22.09 16:55:54.825  INFO [         refresh-10] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'UserInfoProviderImpl.userInfo: [STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM]'. Fetched 10 items in 0 sec. Size: 0 KB. Versions: 3 -> 4.
22.09 16:55:55.300  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 55 ms.
22.09 16:55:55.337  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Get focus monitoring records attributes in 37 ms.
22.09 16:55:56.978  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 124 ms.
22.09 16:56:11.691  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 121 ms.
22.09 16:56:12.049  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 110 ms.
22.09 16:56:12.085  INFO [Dispatcher-worker-2] r.s.p.f.u.c.dao.DslUnifiedRecordsDao    : Found unified records in 140 ms.
22.09 16:56:12.121  INFO [Dispatcher-worker-2] r.s.p.f.u.c.dao.DslUnifiedRecordsDao    : Found unified records in 176 ms.
22.09 16:56:12.156  INFO [Dispatcher-worker-2] r.s.p.f.u.c.dao.DslUnifiedRecordsDao    : Found unified records in 211 ms.
22.09 16:56:12.179  INFO [Dispatcher-worker-2] r.s.p.f.u.c.dao.DslUnifiedRecordsDao    : Found unified records in 232 ms.
22.09 16:56:17.952  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 53 ms.
22.09 16:56:17.987  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Get focus monitoring records attributes in 35 ms.
22.09 16:57:29.847  INFO [         refresh-10] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'UserInfoProviderImpl.userInfo: [BASKET_FOCUS_MONITORING, STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM, STATUS_AGREEMENT_FM, FM_FILE_EXECUTION, REGISTRY_FM, REGISTRY_FM_EMPLOYEE, EDIT_AGREED_FM, INITIATION_FOCUS_MONITORING, FM_AUTOLOAD_RECORDS, DELETE_TASK_FM]'. Fetched 82 items in 0 sec. Size: 0 KB. Versions: 3 -> 4.
22.09 16:57:42.787  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 123 ms.
22.09 16:57:49.586  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 115 ms.
22.09 16:58:05.482  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 117 ms.
22.09 16:58:11.731  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id, statuses and login in 108 ms.
22.09 16:58:11.731  INFO [Dispatcher-worker-1] r.s.p.s.manage.BaseSuspicionManager     : No suspicion entities passed taskId: 616001, process: FocusMonitoring
22.09 16:58:12.623  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 125 ms.
22.09 16:58:25.793  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 126 ms.
22.09 16:58:26.132  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 111 ms.
22.09 17:00:24.060  INFO [         refresh-11] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'UserInfoProviderImpl.userInfo: [STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM]'. Fetched 10 items in 0 sec. Size: 0 KB. Versions: 4 -> 5.
22.09 17:03:13.306  INFO [         refresh-14] r.s.p.e.d.r.core.AbstractRefreshable    : Refreshed 'UserInfoProviderImpl.userInfo: [BASKET_FOCUS_MONITORING, STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM, STATUS_AGREEMENT_FM, FM_FILE_EXECUTION, REGISTRY_FM, REGISTRY_FM_EMPLOYEE, EDIT_AGREED_FM, INITIATION_FOCUS_MONITORING, FM_AUTOLOAD_RECORDS, DELETE_TASK_FM]'. Fetched 82 items in 0 sec. Size: 0 KB. Versions: 4 -> 5.
22.09 17:03:45.724  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 124 ms.
22.09 17:03:54.242  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id, statuses and login in 123 ms.
22.09 17:03:54.242  INFO [Dispatcher-worker-2] r.s.p.s.manage.BaseSuspicionManager     : No suspicion entities passed taskId: 616001, process: FocusMonitoring
22.09 17:03:55.010  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 93 ms.
22.09 17:04:03.307  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id, statuses and login in 107 ms.
22.09 17:04:03.307  INFO [Dispatcher-worker-1] r.s.p.s.manage.BaseSuspicionManager     : No suspicion entities passed taskId: 616001, process: FocusMonitoring
22.09 17:04:03.694  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 94 ms.
22.09 17:04:11.572  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id, statuses and login in 111 ms.
22.09 17:04:11.572  INFO [Dispatcher-worker-1] r.s.p.s.manage.BaseSuspicionManager     : No suspicion entities passed taskId: 616001, process: FocusMonitoring
22.09 17:04:11.956  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 102 ms.
22.09 17:04:16.302  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id, statuses and login in 118 ms.
22.09 17:04:16.302  INFO [Dispatcher-worker-2] r.s.p.s.manage.BaseSuspicionManager     : No suspicion entities passed taskId: 616001, process: FocusMonitoring
22.09 17:04:16.718  INFO [Dispatcher-worker-1] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 91 ms.
22.09 17:04:37.022  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record infos in 48 ms.
22.09 17:04:37.053  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Get focus monitoring records attributes in 31 ms.
22.09 17:04:41.647  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 106 ms.
22.09 17:05:01.812  INFO [Dispatcher-worker-2] r.s.p.f.s.records.dao.DslFmRecordDao    : Find focus monitoring record by id and statuses in 106 ms.
22.09 17:05:01.995  INFO [           trans-04] r.sber.poirot.dpa.client.HttpDpaClient  : Send notify req to dis-pro-adapter taskId=[616001, DONE, FOCUS_MONITORING], taskStatus={}, processType={}
22.09 17:05:02.052 ERROR [Dispatcher-worker-2] a.w.r.e.AbstractErrorWebExceptionHandler: [b05a4b66-890]  500 Server Error for HTTP POST "/api/agreement/agree/616001"

java.util.NoSuchElementException: Collection contains no element matching the predicate.
	at ru.sber.poirot.focus.stages.FmFraudManager.fraudRecords(FmFraudManager.kt:172)
	Suppressed: reactor.core.publisher.FluxOnAssembly$OnAssemblyException:
Error has been observed at the following site(s):
	*__checkpoint ⇢ Handler ru.sber.poirot.focus.stages.agreement.AgreementController#agree(long, Continuation) [DispatcherHandler]
	*__checkpoint ⇢ SecurityConfig$$Lambda$1307/0x0000000801ae60c0 [DefaultWebFilterChain]
	*__checkpoint ⇢ AuthorizationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ExceptionTranslationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ LogoutWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ServerRequestCacheWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ SecurityContextServerWebExchangeWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ AuthenticationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ReactorContextWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ HttpHeaderWriterWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ServerWebExchangeReactorContextWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ org.springframework.security.web.server.WebFilterChainProxy [DefaultWebFilterChain]
	*__checkpoint ⇢ HTTP POST "/api/agreement/agree/616001" [ExceptionHandlingWebHandler]
Original Stack Trace:
		at ru.sber.poirot.focus.stages.FmFraudManager.fraudRecords(FmFraudManager.kt:172)
		at ru.sber.poirot.focus.stages.FmFraudManager.addFrauds$suspendImpl(FmFraudManager.kt:30)
		at ru.sber.poirot.focus.stages.FmFraudManager.addFrauds(FmFraudManager.kt)
		at ru.sber.poirot.fraud.client.FraudManager.addFrauds$suspendImpl(FraudManager.kt:4)
		at ru.sber.poirot.fraud.client.FraudManager.addFrauds(FraudManager.kt)
		at ru.sber.poirot.focus.stages.agreement.AgreementServiceImpl$agree$2.invokeSuspend(AgreementServiceImpl.kt:39)
		at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
		at kotlinx.coroutines.DispatchedTask.run(DispatchedTask.kt:104)
		at kotlinx.coroutines.EventLoopImplBase.processNextEvent(EventLoop.common.kt:277)
		at kotlinx.coroutines.BlockingCoroutine.joinBlocking(Builders.kt:95)
		at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking(Builders.kt:69)
		at kotlinx.coroutines.BuildersKt.runBlocking(Unknown Source)
		at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking$default(Builders.kt:48)
		at kotlinx.coroutines.BuildersKt.runBlocking$default(Unknown Source)
		at ru.sber.poirot.utils.TransactionalUtilsKt$transactionalWithReactorContext$$inlined$transactional$1$1.doInTransaction(Transactions.kt:26)
		at org.springframework.transaction.support.TransactionTemplate.execute(TransactionTemplate.java:140)
		at ru.sber.poirot.utils.TransactionalUtilsKt$transactionalWithReactorContext$$inlined$transactional$1.invokeSuspend(Transactions.kt:25)
		at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
		at kotlinx.coroutines.DispatchedTask.run(DispatchedTask.kt:104)
		at java.base/java.util.concurrent.ForkJoinTask$RunnableExecuteAction.exec(ForkJoinTask.java:1395)
		at java.base/java.util.concurrent.ForkJoinTask.doExec(ForkJoinTask.java:373)
		at java.base/java.util.concurrent.ForkJoinPool$WorkQueue.topLevelExec(ForkJoinPool.java:1182)
		at java.base/java.util.concurrent.ForkJoinPool.scan(ForkJoinPool.java:1655)
		at java.base/java.util.concurrent.ForkJoinPool.runWorker(ForkJoinPool.java:1622)
		at java.base/java.util.concurrent.ForkJoinWorkerThread.run(ForkJoinWorkerThread.java:165)package ru.sber.poirot.focus.stages

import org.springframework.stereotype.Service
import ru.sber.poirot.engine.dictionaries.model.api.fraud.FraudReasonsCorp
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.dictionaries.inProcessFraudsCache
import ru.sber.poirot.focus.shared.dictionaries.model.*
import ru.sber.poirot.focus.shared.dictionaries.model.FraudCode.SUSPICION
import ru.sber.poirot.focus.shared.dictionaries.model.FraudScheme.*
import ru.sber.poirot.focus.shared.dictionaries.model.FraudScheme.Companion.fraudSchemes
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.fraud.client.FraudManager
import ru.sber.poirot.fraud.client.KtorFraudClient
import ru.sber.poirot.fraud.model.FraudRecord
import ru.sber.poirot.fraud.model.FraudRegistryType
import ru.sber.poirot.suspicion.dictionaries.fraudSchemeCorps
import ru.sber.utils.ifNotEmpty
import ru.sber.utils.logger
import java.time.LocalDate
import java.time.LocalDateTime

@Service
class FmFraudManager(private val ktorFraudClient: KtorFraudClient) : FraudManager<FmRecord> {
    private val log = logger()

    override suspend fun addFrauds(records: List<FmRecord>) {
        val inProcessFraudsByCode = inProcessFraudsCache.asMap()
        records.filter { it.confirmedFraud == true }
            .flatMap {
                it.fraudRecords(
                    fraudSchemes = fraudSchemes,
                    canBeDeleted = false,
                    inProcessFraud = inProcessFraudsByCode[it.inProcessFraud],
                )
            }
            .also { log.info("Adding ${it.size} fraud records:\n$it") }
            .ifNotEmpty { ktorFraudClient.addFrauds(it) }
    }

    override suspend fun editFrauds(recordPairs: List<FraudManager.RecordPair<FmRecord>>) {
        val inProcessFraudsByCode = inProcessFraudsCache.asMap()
        recordPairs
            .flatMap {
                it.new.fraudRecords(
                    fraudSchemes = it.getUpdatedFraudSchemes(),
                    canBeDeleted = true,
                    inProcessFraud = inProcessFraudsByCode[it.new.inProcessFraud]
                )
            }
            .also { log.info("Editing ${it.size} fraud records:\n$it") }
            .ifNotEmpty { ktorFraudClient.addFrauds(it) }
    }

    private fun FraudManager.RecordPair<FmRecord>.getUpdatedFraudSchemes(): List<FraudScheme> = buildList {
        if (new.capitalOutFlow != previous.capitalOutFlow) add(CAPITAL_OUTFLOW)
        if (new.bankruptcy != previous.bankruptcy) add(BANKRUPTCY)
        if (new.fakeReportDoc != previous.fakeReportDoc) add(FAKE_DOC)
        if (new.fakeReport != previous.fakeReport) add(FAKE_REPORT)
        if (new.inProcessFraud != previous.inProcessFraud
            || new.summary != previous.summary
            || new.summaryKp != previous.summaryKp
            || new.dateFraud != previous.dateFraud
        ) {
            if (new.capitalOutFlow?.isNotEmpty == true) add(CAPITAL_OUTFLOW)
            if (new.bankruptcy?.isNotEmpty == true) add(BANKRUPTCY)
            if (new.fakeReportDoc?.isNotEmpty == true) add(FAKE_DOC)
            if (new.fakeReport?.isNotEmpty == true) add(FAKE_REPORT)
        }
    }.distinct()

    private fun FmRecord.fraudRecords(
        fraudSchemes: List<FraudScheme>,
        canBeDeleted: Boolean,
        inProcessFraud: String?,
    ): List<FraudRecord> {
        val fraudReasonsCorp = fraudSchemeCorps.asSet().toList()
        return if (processType == 11 && !monitoringProcessFraudSchemas.isNullOrEmpty()) {
            val monitoringFrauds = monitoringProcessFraudSchemas.map { scheme ->
                FraudRecord.fraudRecord(
                    type = FraudRegistryType.LE_CLIENT.type,
                    key = inn!!,
                    keyNoApp = inn,
                    fraudStatus = SUSPICION.code,
                    scheme = fraudReasonsCorp.first { it.id == scheme.fraudSchemeId }.key,
                    source = "monitoring_ksb",
                    fullComment = scheme.fullComment ?: summary,
                    shortComment = scheme.shortComment ?: summaryKp,
                    login = executor,
                    dateTime = LocalDateTime.now(),
                    typeFraud = "Последующий",
                    incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
                    corpControlMode = fmFraudCorpControlMode,
                    fraudAdditionalInfo = null
                )
            }
            val fraudsBySuspicions = fraudRecordsBySuspicions(
                fraudReasonsCorp,
                gfmFraudSource,
                executor ?: throw FrontException("Исполнитель должен быть назначен"),
                gfmTypeFraud
            )

            (monitoringFrauds + fraudsBySuspicions).distinct()
        } else {
            val generalFrauds = fraudSchemes.mapNotNull { it.fraudRecord(this, canBeDeleted, inProcessFraud) }
            val fraudsBySuspicions = fraudRecordsBySuspicions(
                fraudReasonsCorp,
                fmFraudSource,
                fmFraudLogin,
                typeFraud(inProcessFraud)
            )
            (generalFrauds + fraudsBySuspicions).distinct()
        }
    }

    private fun FmRecord.fraudRecordsBySuspicions(
        fraudSchemes: List<FraudReasonsCorp>,
        source: String?,
        login: String,
        typeFraud: String?
    ): List<FraudRecord> = suspicions.suspicions(fraudSchemes)
        .suspicionEntities()
        .map { suspicionEntity ->
            val fraudKey = suspicionEntity.fraudKey()
            FraudRecord.fraudRecord(
                type = fraudKey.type,
                key = fraudKey.key,
                keyNoApp = fraudKey.key,
                fraudStatus = SUSPICION.code,
                scheme = fraudKey.scheme,
                source = source,
                fullComment = summary,
                shortComment = summaryKp,
                login = login,
                dateTime = LocalDateTime.now(),
                typeFraud = typeFraud,
                incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
                corpControlMode = fmFraudCorpControlMode,
                fraudAdditionalInfo = null,
            )
        }
}
