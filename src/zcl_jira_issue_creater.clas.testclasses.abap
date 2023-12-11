
CLASS ltcl_jira DEFINITION
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  " ?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  " ?<asx:values>
  " ?<TESTCLASS_OPTIONS>
  " ?<TEST_CLASS>ltcl_Jira
  " ?</TEST_CLASS>
  " ?<TEST_MEMBER>f_Cut
  " ?</TEST_MEMBER>
  " ?<OBJECT_UNDER_TEST>Z_JIRA_ISSUE_CREATER
  " ?</OBJECT_UNDER_TEST>
  " ?<OBJECT_IS_LOCAL/>
  " ?<GENERATE_FIXTURE>X
  " ?</GENERATE_FIXTURE>
  " ?<GENERATE_CLASS_FIXTURE>X
  " ?</GENERATE_CLASS_FIXTURE>
  " ?<GENERATE_INVOCATION>X
  " ?</GENERATE_INVOCATION>
  " ?<GENERATE_ASSERT_EQUAL>X
  " ?</GENERATE_ASSERT_EQUAL>
  " ?</TESTCLASS_OPTIONS>
  " ?</asx:values>
  " ?</asx:abap>

  PRIVATE SECTION.
    DATA f_cut TYPE REF TO zcl_jira_issue_creater.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.

    METHODS setup.
    METHODS teardown.

    METHODS create_3_issues FOR TESTING.

ENDCLASS.


CLASS ltcl_jira IMPLEMENTATION.
  METHOD class_setup.
  ENDMETHOD.

  METHOD class_teardown.
  ENDMETHOD.

  METHOD setup.
    BREAK-POINT.
    " Add these
    f_cut = NEW #( i_url   = 'https://xxxxxxxxxxxxx.atlassian.net/rest/api/2/issue'
                   i_user  = 'xxxxxxxx.xxxxx@gmail.com'
                   i_token = 'xxxxxxxxxxxxx' ).
  ENDMETHOD.

  METHOD teardown.
  ENDMETHOD.

  METHOD create_3_issues.
    DATA ls_struc TYPE zcl_jira_issue_creater=>ty_new_issue_structure.

    ls_struc-fields-assignee-id = '71xxx20:xxxxxxxx-a3de-xxxxxb8'.
    ls_struc-fields-description = 'Order entry fails when selecting supplier.'.
    ls_struc-fields-issuetype-id = '10001'.
    ls_struc-fields-summary = 'Main order flow broken 22"'.
    ls_struc-fields-project-id = '10000'.

    DATA(ls_result_1) = f_cut->create_jira_issue( is_issue_details = ls_struc ).

    ls_struc-fields-summary = 'Main order flow broken 33"'.

    DATA(ls_result_2) = f_cut->create_jira_issue( is_issue_details = ls_struc ).

    ls_struc-fields-summary = 'Main order flow broken 44"'.

    DATA(ls_result_3) = f_cut->create_jira_issue( is_issue_details = ls_struc ).

    cl_abap_unit_assert=>assert_not_initial( act = ls_result_1
                                             msg = 'Issue 2 not ok' ).

    cl_abap_unit_assert=>assert_not_initial( act = ls_result_2
                                             msg = 'Issue 2 not ok' ).

    cl_abap_unit_assert=>assert_not_initial( act = ls_result_3
                                             msg = 'Issue 3 not ok' ).

    "=> check manually in jira if the three issues got created =D
  ENDMETHOD.
ENDCLASS.
