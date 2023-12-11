CLASS zcl_jira_issue_creater DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      " Result of issue creation
      BEGIN OF ty_new_issue_result_structure,
        id   TYPE string,
        key  TYPE string,
        self TYPE string,
      END OF ty_new_issue_result_structure.
    TYPES:
      " issue creation
      BEGIN OF ty_customfield,
        id TYPE string,
      END OF ty_customfield.
    TYPES:
      BEGIN OF ty_customfield_30000,
        value TYPE string,
      END OF ty_customfield_30000.
    TYPES:
      BEGIN OF ty_customfield_80000,
        value TYPE string,
      END OF ty_customfield_80000.
    TYPES:
      BEGIN OF ty_fix_versions,
        id TYPE string,
      END OF ty_fix_versions.
    TYPES:
      BEGIN OF ty_components,
        id TYPE string,
      END OF ty_components.
    TYPES:
      BEGIN OF ty_priority,
        id TYPE string,
      END OF ty_priority.
    TYPES:
      BEGIN OF ty_versions,
        id TYPE string,
      END OF ty_versions.
    TYPES:
      BEGIN OF ty_worklog_add,
        started   TYPE string,
        timespent TYPE string,
      END OF ty_worklog_add.
    TYPES:
      BEGIN OF ty_worklog,
        add TYPE ty_worklog_add,
      END OF ty_worklog.
    TYPES:
      BEGIN OF ty_update,
        worklog TYPE TABLE OF ty_worklog WITH EMPTY KEY,
      END OF ty_update.
    TYPES:
      BEGIN OF ty_fields,
        assignee          TYPE ty_customfield,
        components        TYPE TABLE OF ty_components WITH EMPTY KEY,
        customfield_10000 TYPE string,
        customfield_20000 TYPE string,
        customfield_30000 TYPE TABLE OF ty_customfield_30000 WITH EMPTY KEY,
        customfield_40000 TYPE string,
        customfield_50000 TYPE string,
        customfield_60000 TYPE string,
        customfield_70000 TYPE TABLE OF string WITH EMPTY KEY,
        customfield_80000 TYPE ty_customfield_80000,
        description       TYPE string,
        duedate           TYPE string,
        environment       TYPE string,
        fixversions       TYPE TABLE OF ty_fix_versions WITH EMPTY KEY,
        issuetype         TYPE ty_customfield,
        labels            TYPE TABLE OF string WITH EMPTY KEY,
        parent            TYPE ty_customfield,
        priority          TYPE ty_priority,
        reporter          TYPE ty_customfield,
        security          TYPE ty_customfield,
        summary           TYPE string,
        project           TYPE ty_customfield,
        timetracking      TYPE TABLE OF string WITH EMPTY KEY,
        versions          TYPE TABLE OF ty_versions WITH EMPTY KEY,
      END OF ty_fields.
    TYPES:
      BEGIN OF ty_new_issue_structure,
        fields TYPE ty_fields,
        update TYPE ty_update,
      END OF ty_new_issue_structure.

    METHODS constructor
      IMPORTING i_url   TYPE string
                i_user  TYPE string
                i_token TYPE string.

    METHODS create_jira_issue
      IMPORTING is_issue_details TYPE zcl_jira_issue_creater=>ty_new_issue_structure
      RETURNING VALUE(rs_result) TYPE zcl_jira_issue_creater=>ty_new_issue_result_structure.

  PRIVATE SECTION.
    DATA m_url     TYPE string.
    DATA m_user    TYPE string.
    DATA m_token   TYPE string.
    DATA mo_client TYPE REF TO if_http_client.

    METHODS send_and_receive.
    METHODS prepare_client.

    METHODS prep_client_for_issue_creation
      IMPORTING is_issue_details TYPE zcl_jira_issue_creater=>ty_new_issue_structure.

    METHODS get_issue_creation_result
      RETURNING VALUE(rs_result) TYPE zcl_jira_issue_creater=>ty_new_issue_result_structure.
ENDCLASS.


CLASS zcl_jira_issue_creater IMPLEMENTATION.
  METHOD constructor.
    m_url = i_url.
    m_user = i_user.
    m_token = i_token.
  ENDMETHOD.

  METHOD create_jira_issue.
    prep_client_for_issue_creation( is_issue_details ).

    send_and_receive( ).

    rs_result = get_issue_creation_result( ).

    mo_client->close( EXCEPTIONS http_invalid_state = 1
                                 OTHERS             = 2 ).
  ENDMETHOD.

  METHOD get_issue_creation_result.
    DATA(l_result) = mo_client->response->get_cdata( ).

    /ui2/cl_json=>deserialize( EXPORTING json = l_result
*                                         jsonx =
*                                         pretty_name =
*                                         assoc_arrays =
*                                         assoc_arrays_opt =
*                                         name_mappings =
*                                         conversion_exits =
                               CHANGING  data = rs_result ).
  ENDMETHOD.

  METHOD prepare_client.
    IF mo_client IS BOUND.

      mo_client->refresh_request( ).
      mo_client->refresh_request( ).

    ELSE.

      cl_http_client=>create_by_url( EXPORTING  url                = m_url
                                     IMPORTING  client             = mo_client
                                     EXCEPTIONS argument_not_found = 1
                                                plugin_not_active  = 2
                                                internal_error     = 3
                                                OTHERS             = 4 ).
      IF sy-subrc <> 0.
        " todo
      ENDIF.

    ENDIF.

    mo_client->authenticate( username = m_user
                             password = m_token ).
  ENDMETHOD.

  METHOD prep_client_for_issue_creation.
    prepare_client( ).

    mo_client->request->set_method( cl_http_entity=>co_request_method_post ).
    mo_client->request->set_content_type( 'application/json' ).
    mo_client->request->set_version( version = cl_http_entity=>co_protocol_version_1_1 ).

    DATA(l_issue) = /ui2/cl_json=>serialize( data        = is_issue_details
                                             compress    = abap_true
*                                             name        =
                                             pretty_name = /ui2/cl_json=>pretty_mode-low_case
*                                             type_descr  =
*                                             assoc_arrays =
*                                             ts_as_iso8601 =
*                                             expand_includes =
*                                             assoc_arrays_opt =
*                                             numc_as_string =
*                                             name_mappings =
*                                             conversion_exits =
                      ).

    mo_client->request->set_cdata( l_issue ).
  ENDMETHOD.

  METHOD send_and_receive.
    TRY.
        mo_client->send( EXCEPTIONS http_communication_failure = 1
                                    http_invalid_state         = 2
                                    http_processing_failed     = 3
                                    http_invalid_timeout       = 4
                                    OTHERS                     = 5 ).
        IF sy-subrc <> 0.
          " todo
        ENDIF.

        mo_client->receive( EXCEPTIONS http_communication_failure = 1
                                       http_invalid_state         = 2
                                       http_processing_failed     = 3
                                       OTHERS                     = 4 ).
        IF sy-subrc <> 0.
          " todo
        ENDIF.

      CATCH cx_root.

        mo_client->close( EXCEPTIONS http_invalid_state = 1
                                     OTHERS             = 2 ).

        " todo

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
