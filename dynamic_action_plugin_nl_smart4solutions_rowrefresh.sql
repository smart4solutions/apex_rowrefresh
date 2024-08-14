prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2024.05.31'
,p_release=>'24.1.3'
,p_default_workspace_id=>36728649485285263261
,p_default_application_id=>116877
,p_default_id_offset=>25447798276862251141
,p_default_owner=>'SMART4SOLUTIONS'
);
end;
/
 
prompt APPLICATION 116877 - smart4solutions (Working Copy: jordy)
--
-- Application Export:
--   Application:     116877
--   Name:            smart4solutions (Working Copy: jordy)
--   Date and Time:   18:51 Wednesday August 14, 2024
--   Exported By:     JKIESEBRINK@SMART4SOLUTIONS.NL
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 25511046063764227702
--   Manifest End
--   Version:         24.1.3
--   Instance ID:     63113759365424
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/nl_smart4solutions_rowrefresh
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(25511046063764227702)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'NL_SMART4SOLUTIONS_ROWREFRESH'
,p_display_name=>'SMART4Solutions Rowrefresh'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>'#PLUGIN_FILES#main#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- Author  : JKIESEBRINK@SMART4SOLUTIONS.NL',
'-- Created : 7/27/2024 12:26:12 AM',
'-- Purpose : Oracle APEX Dynamic Action Plug-in',
'',
'-- Public type declarations',
'type tt_col_type is table of varchar2(4000) index by varchar2(1000);',
'',
'-- Public function and procedure declarations',
'function fn_init(p_dynamic_action in apex_plugin.t_dynamic_action',
'                ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_render_result as',
'    l_result apex_plugin.t_dynamic_action_render_result;',
'begin',
'    l_result.javascript_function := ''s4s.apex.rowrefresh.init'';',
'    l_result.ajax_identifier     := apex_plugin.get_ajax_identifier;',
'    l_result.attribute_01        := p_dynamic_action.attribute_01; -- jQuery Selector',
'    l_result.attribute_02        := p_dynamic_action.attribute_02; -- Template Name',
'    l_result.attribute_03        := p_dynamic_action.attribute_03; -- Source: SQL Query',
'    l_result.attribute_04        := p_dynamic_action.attribute_04; -- Source: Items to submit',
'    l_result.attribute_05        := p_dynamic_action.attribute_05; -- Row Identifier',
'',
'    return l_result;',
'end fn_init;',
'',
'function fn_get_cursor_data(i_cursor in out sys_refcursor) return tt_col_type is',
'    l_cursor_id   number;',
'    l_cursor_desc dbms_sql.desc_tab;',
'    l_col_count   number;',
'    l_tmp_value   varchar2(4000);',
'    l_col_tab     tt_col_type := new tt_col_type();',
'begin',
'    l_cursor_id := dbms_sql.to_cursor_number(rc => i_cursor);',
'    dbms_sql.describe_columns(c       => l_cursor_id',
'                             ,col_cnt => l_col_count',
'                             ,desc_t  => l_cursor_desc);',
'  ',
'    for i in 1 .. l_col_count',
'    loop',
'      dbms_sql.define_column(c           => l_cursor_id',
'                            ,position    => i',
'                            ,column      => l_tmp_value',
'                            ,column_size => 4000);',
'    end loop;',
'  ',
'    while dbms_sql.fetch_rows(c => l_cursor_id) > 0',
'    loop',
'      for i in 1 .. l_col_count',
'      loop',
'        dbms_sql.column_value(c        => l_cursor_id',
'                             ,position => i',
'                             ,value    => l_tmp_value);',
'        l_col_tab(l_cursor_desc(i).col_name) := l_tmp_value;',
'      end loop;',
'    end loop;',
'  ',
'    return l_col_tab;',
'end fn_get_cursor_data;',
'',
'function fn_replace_template_vars(i_col_tab  in tt_col_type',
'                                 ,i_template in clob) return clob is',
'    l_result    clob := i_template;',
'    l_pattern   varchar2(12) := ''#[A-Z0-9_]+#'';',
'    l_match     varchar2(1000);',
'    l_start     number := 1;',
'    l_col_name  varchar2(1000);',
'    l_col_value varchar2(4000);',
'begin',
'    loop',
'      l_match := regexp_substr(srcstr     => l_result',
'                              ,pattern    => l_pattern',
'                              ,position   => l_start',
'                              ,occurrence => 1);',
'      exit when l_match is null;',
'    ',
'      -- Extract the placeholder name, remove the # symbols',
'      l_col_name := substr(l_match',
'                          ,2',
'                          ,length(l_match) - 2);',
'    ',
'      if i_col_tab.exists(upper(l_col_name))',
'      then',
'        l_col_value := i_col_tab(upper(l_col_name));',
'        l_result    := replace(srcstr => l_result',
'                              ,oldsub => l_match',
'                              ,newsub => l_col_value);',
'      ',
'        -- Move the start position past the new content',
'        l_start := l_start + length(l_col_value) - 1;',
'      else',
'        -- Skip the placeholder and move past it',
'        l_start := l_start + length(l_match);',
'      end if;',
'    end loop;',
'  ',
'    return l_result;',
'end fn_replace_template_vars;',
'',
'function fn_evaluate_condition(i_condition in varchar2',
'                              ,i_col_tab   in tt_col_type) return boolean is',
'    l_cond      varchar2(4000);',
'    l_result    boolean;',
'    l_cursor_id integer;',
'    l_dummy     integer;',
'    l_var_name  varchar2(1000);',
'begin',
'    if i_condition is null',
'    then',
'        return true;',
'    end if;',
'    ',
'    -- Substitute variables in condition',
'    l_cond := fn_replace_template_vars(i_col_tab  => i_col_tab',
'                                      ,i_template => i_condition);',
'  ',
'    -- Prepare dynamic SQL for the condition',
'    l_cursor_id := dbms_sql.open_cursor;',
'    dbms_sql.parse(c             => l_cursor_id',
'                  ,statement     => ''BEGIN :result := ('' || l_cond || ''); END;''',
'                  ,language_flag => dbms_sql.native);',
'    dbms_sql.bind_variable(c     => l_cursor_id',
'                          ,name  => '':result''',
'                          ,value => l_result);',
'  ',
'    -- Handle all variables in the condition string',
'    for r_bind in (select distinct regexp_substr(l_cond',
'                                                ,'':[^:() ,]+''',
'                                                ,1',
'                                                ,level) as var_name',
'                   from   dual',
'                   connect by regexp_substr(l_cond',
'                                           ,'':[^:() ,]+''',
'                                           ,1',
'                                           ,level) is not null)',
'    loop',
'      l_var_name := substr(r_bind.var_name',
'                          ,2);',
'      dbms_sql.bind_variable(c     => l_cursor_id',
'                            ,name  => r_bind.var_name',
'                            ,value => case',
'                                        when i_col_tab.exists(l_var_name) then',
'                                         i_col_tab(l_var_name)',
'                                        else',
'                                         null',
'                                      end);',
'    end loop;',
'  ',
'    l_dummy := dbms_sql.execute(c => l_cursor_id);',
'    dbms_sql.variable_value(c     => l_cursor_id',
'                           ,name  => '':result''',
'                           ,value => l_result);',
'    dbms_sql.close_cursor(c => l_cursor_id);',
'  ',
'    return l_result;',
'end fn_evaluate_condition;',
'',
'function fn_get_template(i_template_name in varchar2',
'                        ,i_col_tab       in tt_col_type) return clob is',
'    l_template clob;',
'begin',
'    for r_temp in (select temp.col_template1',
'                         ,temp.col_template_condition1',
'                         ,temp.col_template2',
'                         ,temp.col_template_condition2',
'                         ,temp.col_template3',
'                         ,temp.col_template_condition3',
'                         ,temp.col_template4',
'                         ,temp.col_template_condition4',
'                   from   apex_application_temp_report temp',
'                   where  temp.template_name = i_template_name)',
'    loop',
'      if fn_evaluate_condition(i_condition => r_temp.col_template_condition1',
'                              ,i_col_tab   => i_col_tab)',
'      then',
'        l_template := r_temp.col_template1;',
'      elsif fn_evaluate_condition(i_condition => r_temp.col_template_condition2',
'                                 ,i_col_tab   => i_col_tab)',
'      then',
'        l_template := r_temp.col_template2;',
'      elsif fn_evaluate_condition(i_condition => r_temp.col_template_condition3',
'                                 ,i_col_tab   => i_col_tab)',
'      then',
'        l_template := r_temp.col_template3;',
'      elsif fn_evaluate_condition(i_condition => r_temp.col_template_condition4',
'                                 ,i_col_tab   => i_col_tab)',
'      then',
'        l_template := r_temp.col_template4;',
'      end if;',
'    end loop;',
'  ',
'    return l_template;',
'end fn_get_template;',
'',
'function fn_refresh_row(p_dynamic_action in apex_plugin.t_dynamic_action',
'                       ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_ajax_result as',
'    l_result     apex_plugin.t_dynamic_action_ajax_result;',
'    l_cursor_id  number;',
'    l_cursor     sys_refcursor;',
'    l_page_items apex_application_global.vc_arr2;',
'    l_dummy      number;',
'    l_key_value  tt_col_type;',
'    l_row_html   clob;',
'    l_template   clob;',
'begin',
'    -- Open the cursor for the selected row',
'    l_cursor_id := dbms_sql.open_cursor;',
'    dbms_sql.parse(c             => l_cursor_id',
'                  ,statement     => p_dynamic_action.attribute_03',
'                  ,language_flag => dbms_sql.native);',
'',
'    -- Parse the list of page items to submit',
'    l_page_items := apex_util.string_to_table(p_string => p_dynamic_action.attribute_04);',
'    ',
'    -- Loop over each page item, fetch its value from session state, and bind it',
'    for i in 1 .. l_page_items.count',
'    loop',
'        dbms_sql.bind_variable(c     => l_cursor_id',
'                              ,name  => l_page_items(i)',
'                              ,value => v(l_page_items(i)));',
'    end loop;',
'',
'    l_dummy := dbms_sql.execute(c => l_cursor_id);',
'  ',
'    -- Use the function to get cursor data as key-value pairs',
'    l_cursor    := dbms_sql.to_refcursor(cursor_number => l_cursor_id);',
'    l_key_value := fn_get_cursor_data(i_cursor => l_cursor);',
'  ',
'    -- Get the correct template',
'    l_template := fn_get_template(i_template_name => p_dynamic_action.attribute_02',
'                                 ,i_col_tab       => l_key_value);',
'  ',
'    -- Replace the template variables with values from key-value pairs',
'    l_row_html := fn_replace_template_vars(i_col_tab  => l_key_value',
'                                          ,i_template => l_template);',
'',
'    apex_json.open_object;',
'    apex_json.write(p_name => ''jquery_selector''',
'                   ,p_value => p_dynamic_action.attribute_01);',
'    apex_json.write(p_name => ''template_name''',
'                   ,p_value => p_dynamic_action.attribute_02);',
'    apex_json.write(p_name => ''source_query''',
'                   ,p_value => p_dynamic_action.attribute_03);',
'    apex_json.write(p_name => ''items_to_submit''',
'                   ,p_value => p_dynamic_action.attribute_04);',
'    apex_json.write(p_name => ''row_identifier''',
'                   ,p_value => p_dynamic_action.attribute_05);',
'    apex_json.write(p_name  => ''row_html''',
'                   ,p_value => l_row_html',
'                   ,p_write_null => true);',
'    apex_json.close_object;',
'',
'    return l_result;',
'end fn_refresh_row;'))
,p_api_version=>1
,p_render_function=>'fn_init'
,p_ajax_function=>'fn_refresh_row'
,p_standard_attributes=>'BUTTON:REGION:JQUERY_SELECTOR:TRIGGERING_ELEMENT:REQUIRED:ONLOAD:STOP_EXECUTION_ON_ERROR:WAIT_FOR_RESULT'
,p_substitute_attributes=>true
,p_version_scn=>15553867750000
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0.1'
,p_about_url=>'https://apex.oracle.com/pls/apex/f?p=smart4solutions:s4srowrefresh'
,p_files_version=>121
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(25511185221756918341)
,p_plugin_id=>wwv_flow_imp.id(25511046063764227702)
,p_title=>'Source'
,p_display_sequence=>1
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(25511066195464627658)
,p_plugin_id=>wwv_flow_imp.id(25511046063764227702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Row Selector (jQuery Selector)'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'tr[data-row-id]'
,p_help_text=>'A jQuery selector that targets the row closest to the triggering element. The plug-in searches for the first occurrence of this selector starting from the triggering element.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(25511066909165629037)
,p_plugin_id=>wwv_flow_imp.id(25511046063764227702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>30
,p_prompt=>'Template Name'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'My Custom Template'
,p_help_text=>'The name of the template used for rendering the row. The correct row template is selected based on the evaluated PL/SQL expression (template condition).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(25511192913926011403)
,p_plugin_id=>wwv_flow_imp.id(25511046063764227702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>10
,p_prompt=>'SQL Query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(25511185221756918341)
,p_examples=>'SELECT * FROM my_table WHERE id = :P1_ITEM1'
,p_help_text=>'A PL/SQL block that returns the specific row data. Ensure that all bind or substitution variables used in the template condition are part of this query.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(25511722417261294851)
,p_plugin_id=>wwv_flow_imp.id(25511046063764227702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>20
,p_prompt=>'Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(25511185221756918341)
,p_examples=>'P1_ITEM1,P1_ITEM2'
,p_help_text=>'A comma-separated list of page items to submit to the server for session state management. Ensure all necessary page items used in the query and conditions are included here.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(25512988954283064269)
,p_plugin_id=>wwv_flow_imp.id(25511046063764227702)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>20
,p_prompt=>'Row Identifier'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'P1_ITEM1'
,p_help_text=>'The name of the page-item used for identifying the row. The plug-in will go through all data attributes of the matched items for the jQuery Selector to identify the correct row.'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(25511053578090410370)
,p_plugin_id=>wwv_flow_imp.id(25511046063764227702)
,p_name=>'after_refresh'
,p_display_name=>'Ajax Callback for Refresh Row'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '69662028747970656F6620733473203D3D3D2027756E646566696E65642729207B0A2020202076617220733473203D207B7D3B0A7D0A7334732E61706578203D207334732E61706578207C7C207B7D3B0A0A7334732E617065782E726F77726566726573';
wwv_flow_imp.g_varchar2_table(2) := '68203D207B0A202020202F2F20496E697469616C697A6520746865206D6F64756C650A2020202027696E6974273A2066756E6374696F6E202829207B0A20202020202020207334732E617065782E726F77726566726573682E68616E646C654368616E67';
wwv_flow_imp.g_varchar2_table(3) := '6528746869732E616374696F6E2C20746869732E74726967676572696E67456C656D656E74293B0A202020207D2C0A0A202020202F2F2048616E646C6520746865206368616E6765206576656E740A202020202768616E646C654368616E6765273A2066';
wwv_flow_imp.g_varchar2_table(4) := '756E6374696F6E2028616374696F6E2C20656C656D656E7429207B0A202020202020202076617220656C656D656E7453656C6563746F72203D20616374696F6E2E61747472696275746530313B0A202020202020202076617220726F774964656E746966';
wwv_flow_imp.g_varchar2_table(5) := '696572203D20617065782E6974656D28616374696F6E2E6174747269627574653035292E67657456616C756528293B0A2020202020202020766172206D617463686564456C656D656E74203D206E756C6C3B0A0A20202020202020202F2F20436F6E7665';
wwv_flow_imp.g_varchar2_table(6) := '7274207468652070616765206974656D732061747472696275746520746F20612073656C6563746F7220737472696E670A202020202020202076617220706167654974656D7353656C6563746F72203D20616374696F6E2E61747472696275746530340A';
wwv_flow_imp.g_varchar2_table(7) := '2020202020202020202020202E73706C697428272C27290A2020202020202020202020202E6D61702866756E6374696F6E20286974656D29207B2072657475726E20272327202B206974656D2E7472696D28293B207D290A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(8) := '2E6A6F696E28272C27293B0A0A20202020202020202F2F204D616B6520616E20414A41582063616C6C20746F2066657463682074686520646174610A20202020202020207334732E617065782E726F77726566726573682E6665746368526F7744617461';
wwv_flow_imp.g_varchar2_table(9) := '28616374696F6E2E616A61784964656E7469666965722C20706167654974656D7353656C6563746F72292E7468656E2866756E6374696F6E20286461746129207B0A20202020202020202020202069662028726F774964656E74696669657229207B0A20';
wwv_flow_imp.g_varchar2_table(10) := '2020202020202020202020202020202F2F2049746572617465206F7665722065616368206D61746368696E6720656C656D656E74207768656E2074686520726F77206964656E74696669657220697320617661696C61626C650A20202020202020202020';
wwv_flow_imp.g_varchar2_table(11) := '202020202020646F63756D656E742E717565727953656C6563746F72416C6C28656C656D656E7453656C6563746F72292E666F72456163682866756E6374696F6E2028656C656D656E7429207B0A20202020202020202020202020202020202020202F2F';
wwv_flow_imp.g_varchar2_table(12) := '204C6F6F70207468726F75676820616C6C2064617461206174747269627574657320746F2066696E642061206D617463680A2020202020202020202020202020202020202020666F722028766172206B657920696E20656C656D656E742E646174617365';
wwv_flow_imp.g_varchar2_table(13) := '7429207B0A20202020202020202020202020202020202020202020202069662028656C656D656E742E646174617365745B6B65795D203D3D3D20726F774964656E74696669657229207B0A20202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(14) := '2020206D617463686564456C656D656E74203D20656C656D656E743B0A20202020202020202020202020202020202020202020202020202020627265616B3B0A2020202020202020202020202020202020202020202020207D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(15) := '202020202020202020207D0A0A2020202020202020202020202020202020202020696620286D617463686564456C656D656E7429207B0A20202020202020202020202020202020202020202020202072657475726E2066616C73653B0A20202020202020';
wwv_flow_imp.g_varchar2_table(16) := '202020202020202020202020207D0A202020202020202020202020202020207D293B0A2020202020202020202020207D20656C7365207B0A202020202020202020202020202020202F2F2046616C6C6261636B20746F2074686520636C6F73657374206D';
wwv_flow_imp.g_varchar2_table(17) := '61746368696E6720656C656D656E74206966206E6F206964656E7469666965722069732070726F76696465640A202020202020202020202020202020206D617463686564456C656D656E74203D20656C656D656E742E636C6F7365737428656C656D656E';
wwv_flow_imp.g_varchar2_table(18) := '7453656C6563746F72293B0A2020202020202020202020207D0A0A202020202020202020202020696620286D617463686564456C656D656E7429207B0A202020202020202020202020202020202F2F204164642061706578206576656E7420666F722073';
wwv_flow_imp.g_varchar2_table(19) := '75636365737366756C20726566726573680A20202020202020202020202020202020617065782E6576656E742E74726967676572286D617463686564456C656D656E742C202761667465725F7265667265736827293B0A0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(20) := '202020202F2F205265706C6163652074686520656C656D656E74207769746820746865206E657720646174610A202020202020202020202020202020206D617463686564456C656D656E742E6F7574657248544D4C203D20646174612E726F775F68746D';
wwv_flow_imp.g_varchar2_table(21) := '6C3B0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020636F6E736F6C652E6572726F722827456C656D656E74206E6F7420666F756E6420666F722073656C6563746F723A20272C20656C656D656E7453656C';
wwv_flow_imp.g_varchar2_table(22) := '6563746F72293B0A2020202020202020202020207D0A20202020202020207D292E63617463682866756E6374696F6E20286572726F7229207B0A202020202020202020202020636F6E736F6C652E7461626C65286572726F72293B0A2020202020202020';
wwv_flow_imp.g_varchar2_table(23) := '7D293B0A202020207D2C0A0A202020202F2F2046657463682074686520726F772064617461207573696E6720414A41580A20202020276665746368526F7744617461273A2066756E6374696F6E2028616A61784964656E7469666965722C207061676549';
wwv_flow_imp.g_varchar2_table(24) := '74656D7329207B0A202020202020202072657475726E206E65772050726F6D6973652866756E6374696F6E20287265736F6C76652C2072656A65637429207B0A202020202020202020202020617065782E7365727665722E706C7567696E28616A617849';
wwv_flow_imp.g_varchar2_table(25) := '64656E7469666965722C207B0A20202020202020202020202020202020706167654974656D733A20706167654974656D730A2020202020202020202020207D2C207B0A20202020202020202020202020202020737563636573733A2066756E6374696F6E';
wwv_flow_imp.g_varchar2_table(26) := '20286461746129207B0A20202020202020202020202020202020202020207265736F6C76652864617461293B0A202020202020202020202020202020207D2C0A202020202020202020202020202020206572726F723A2066756E6374696F6E2028657272';
wwv_flow_imp.g_varchar2_table(27) := '6F7229207B0A202020202020202020202020202020202020202072656A656374286572726F72293B0A202020202020202020202020202020207D0A2020202020202020202020207D293B0A20202020202020207D293B0A202020207D0A7D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(25511053975658447980)
,p_plugin_id=>wwv_flow_imp.id(25511046063764227702)
,p_file_name=>'main.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '696628766F696420303D3D3D73347329766172207334733D7B7D3B7334732E617065783D7334732E617065787C7C7B7D2C7334732E617065782E726F77726566726573683D7B696E69743A66756E6374696F6E28297B7334732E617065782E726F777265';
wwv_flow_imp.g_varchar2_table(2) := '66726573682E68616E646C654368616E676528746869732E616374696F6E2C746869732E74726967676572696E67456C656D656E74297D2C68616E646C654368616E67653A66756E6374696F6E28652C74297B76617220723D652E617474726962757465';
wwv_flow_imp.g_varchar2_table(3) := '30312C6E3D617065782E6974656D28652E6174747269627574653035292E67657456616C756528292C613D6E756C6C2C6F3D652E61747472696275746530342E73706C697428222C22292E6D6170282866756E6374696F6E2865297B72657475726E2223';
wwv_flow_imp.g_varchar2_table(4) := '222B652E7472696D28297D29292E6A6F696E28222C22293B7334732E617065782E726F77726566726573682E6665746368526F774461746128652E616A61784964656E7469666965722C6F292E7468656E282866756E6374696F6E2865297B6E3F646F63';
wwv_flow_imp.g_varchar2_table(5) := '756D656E742E717565727953656C6563746F72416C6C2872292E666F7245616368282866756E6374696F6E2865297B666F7228766172207420696E20652E6461746173657429696628652E646174617365745B745D3D3D3D6E297B613D653B627265616B';
wwv_flow_imp.g_varchar2_table(6) := '7D696628612972657475726E21317D29293A613D742E636C6F736573742872292C613F28617065782E6576656E742E7472696767657228612C2261667465725F7265667265736822292C612E6F7574657248544D4C3D652E726F775F68746D6C293A636F';
wwv_flow_imp.g_varchar2_table(7) := '6E736F6C652E6572726F722822456C656D656E74206E6F7420666F756E6420666F722073656C6563746F723A20222C72297D29292E6361746368282866756E6374696F6E2865297B636F6E736F6C652E7461626C652865297D29297D2C6665746368526F';
wwv_flow_imp.g_varchar2_table(8) := '77446174613A66756E6374696F6E28652C74297B72657475726E206E65772050726F6D697365282866756E6374696F6E28722C6E297B617065782E7365727665722E706C7567696E28652C7B706167654974656D733A747D2C7B737563636573733A6675';
wwv_flow_imp.g_varchar2_table(9) := '6E6374696F6E2865297B722865297D2C6572726F723A66756E6374696F6E2865297B6E2865297D7D297D29297D7D3B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(25551019428372346060)
,p_plugin_id=>wwv_flow_imp.id(25511046063764227702)
,p_file_name=>'main.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
