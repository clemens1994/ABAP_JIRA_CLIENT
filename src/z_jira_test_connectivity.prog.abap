*&---------------------------------------------------------------------*
*& Report Z_JIRA_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_jira_test_connectivity.


DATA: l_http_status_code TYPE i,
      l_reason           TYPE string,
      go_client          TYPE REF TO if_http_client,
      l_result           TYPE string.

PARAMETERS: p_url   TYPE string OBLIGATORY LOWER CASE,
            p_issue TYPE string OBLIGATORY LOWER CASE,
            p_user  TYPE string OBLIGATORY LOWER CASE,
            p_token TYPE string OBLIGATORY LOWER CASE.


p_url    = p_url && '/rest/api/2/issue/'.
p_url    = p_url && p_issue.

CALL METHOD cl_http_client=>create_by_url
  EXPORTING
    url                = p_url
  IMPORTING
    client             = go_client
  EXCEPTIONS
    argument_not_found = 1
    plugin_not_active  = 2
    internal_error     = 3
    OTHERS             = 4.
IF sy-subrc NE 0.
  MESSAGE 'Failed to create HTTP service URL' TYPE 'E' DISPLAY LIKE 'I'.
ENDIF.


CALL METHOD go_client->authenticate
  EXPORTING
    username = p_user
    password = p_token.

go_client->request->set_method( cl_http_entity=>co_request_method_get ).
go_client->request->set_content_type( 'application/json' ).
go_client->request->set_version( version = cl_http_entity=>co_protocol_version_1_1 ).


TRY.
    go_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        OTHERS                     = 5 ).
    IF sy-subrc NE 0.
      MESSAGE 'Send not successful' TYPE 'E' DISPLAY LIKE 'I'.
    ENDIF.


    go_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).
    IF sy-subrc NE 0.
      MESSAGE 'Receive not successful' TYPE 'E' DISPLAY LIKE 'I'.
    ENDIF.

  CATCH cx_root INTO DATA(lo_exp).

    go_client->close(
     EXCEPTIONS
       http_invalid_state = 1
       OTHERS             = 2 ).

    IF lo_exp->get_text( ) IS NOT INITIAL.
      MESSAGE lo_exp->get_text( ) TYPE 'E' DISPLAY LIKE 'I'.
    ENDIF.

ENDTRY.


CALL METHOD go_client->response->get_status
  IMPORTING
    code   = l_http_status_code
    reason = l_reason.
IF l_http_status_code = 0
OR l_http_status_code = 200.

  CALL METHOD go_client->response->get_cdata
    RECEIVING
      data = l_result.

  SPLIT l_result AT ':' INTO TABLE DATA(lt_issue).

  LOOP AT lt_issue INTO DATA(line).
    WRITE line.
  ENDLOOP.

ENDIF.

go_client->close(
  EXCEPTIONS
    http_invalid_state = 1
    OTHERS             = 2 ).
