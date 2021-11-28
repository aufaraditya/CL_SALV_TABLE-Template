
*&---------------------------------------------------------------------*
*& Report zcl_salv_table_events
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zre_cl_salv_table_template_imp.

*----------------------------------------------------------------------*
*       CLASS cl_event_handler DEFINITION
*-----------------------------------------------------------------------*
CLASS cl_event_handler DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS on_before_salv_function         " BEFORE_SALV_FUNCTION
      FOR EVENT if_salv_events_functions~before_salv_function
      OF cl_salv_events_table
      IMPORTING e_salv_function.

    CLASS-METHODS on_after_salv_function          " AFTER_SALV_FUNCTION
      FOR EVENT if_salv_events_functions~before_salv_function
      OF cl_salv_events_table
      IMPORTING e_salv_function.

    CLASS-METHODS on_added_function               " ADDED_FUNCTION
      FOR EVENT if_salv_events_functions~added_function
      OF cl_salv_events_table
      IMPORTING e_salv_function.

    CLASS-METHODS on_top_of_page                  " TOP_OF_PAGE
      FOR EVENT if_salv_events_list~top_of_page
      OF cl_salv_events_table
      IMPORTING r_top_of_page
                page
                table_index.

    CLASS-METHODS on_end_of_page                  " END_OF_PAGE
      FOR EVENT if_salv_events_list~end_of_page
      OF cl_salv_events_table
      IMPORTING r_end_of_page
                page.

    CLASS-METHODS on_double_click                 " DOUBLE_CLICK
      FOR EVENT if_salv_events_actions_table~double_click
      OF cl_salv_events_table
      IMPORTING row
                column.

    CLASS-METHODS on_link_click                   " LINK_CLICK
      FOR EVENT if_salv_events_actions_table~link_click
      OF cl_salv_events_table
      IMPORTING row
                column.
ENDCLASS.                    "cl_event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS cl_event_handler IMPLEMENTATION.

  METHOD on_before_salv_function.
    BREAK-POINT.
  ENDMETHOD.                    "on_before_salv_function

  METHOD on_after_salv_function.
    BREAK-POINT.
  ENDMETHOD.                    "on_after_salv_function

  METHOD on_added_function.
*    ADD USER COMMAND HERE: FOR EXAMPLE IF THERE IS AN EXPORT BUTTON FOR XLS
*    YOU CAN WRITE THE CODE LIKE THIS:

    IF e_salv_function EQ '&TEST'.  "&TEST IS THE BUTTON FUNCTION CODE
      BREAK-POINT.
    ENDIF.
  ENDMETHOD.                    "on_added_function

  METHOD on_top_of_page.
    BREAK-POINT.
  ENDMETHOD.                    "on_top_of_page

  METHOD on_end_of_page.
    BREAK-POINT.
  ENDMETHOD.                    "on_end_of_page

  METHOD on_double_click.
    BREAK-POINT.
  ENDMETHOD.                    "on_double_click

  METHOD on_link_click.
    BREAK-POINT.
  ENDMETHOD.                    "on_link_click
ENDCLASS.                    "cl_event_handler IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* read sample data to internal table
  SELECT * FROM usr02 UP TO 30 ROWS
    APPENDING TABLE @DATA(gt_usr)
    ORDER BY bname.

  PERFORM display_alv.

*&---------------------------------------------------------------------*
*&      Form  display_alv
*&---------------------------------------------------------------------*
FORM display_alv.

  DATA:
    lo_table   TYPE REF TO cl_salv_table,
    lo_columns TYPE REF TO cl_salv_columns_table,
    lo_column  TYPE REF TO cl_salv_column_list.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_table CHANGING t_table = gt_usr ).

      DATA(lo_events) = lo_table->get_event( ).
      DATA(display_settings) = lo_table->get_display_settings( ).
      display_settings->set_striped_pattern( if_salv_c_bool_sap=>true ).
      display_settings->set_list_header( 'Flight Schedule' ). "Report Title

      SET HANDLER cl_event_handler=>on_before_salv_function FOR lo_events.
      SET HANDLER cl_event_handler=>on_after_salv_function FOR lo_events.
      SET HANDLER cl_event_handler=>on_added_function FOR lo_events.
      SET HANDLER cl_event_handler=>on_top_of_page FOR lo_events.
      SET HANDLER cl_event_handler=>on_end_of_page FOR lo_events.
      SET HANDLER cl_event_handler=>on_double_click FOR lo_events.
      SET HANDLER cl_event_handler=>on_link_click FOR lo_events.

*     ALV-Toolbar ------------------------------------------------------------------------------------------
      lo_table->set_screen_status(
        pfstatus      = 'ZSTANDARD'
        report        = 'ZRE_CL_SALV_TABLE_TEMPLATE'
        set_functions = lo_table->c_functions_all ).

*     Set column as hotspot --------------------------------------------------------------------------------
      lo_columns = lo_table->get_columns( ).
      lo_column ?= lo_columns->get_column( 'BNAME' ).
      lo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

      lo_columns->set_optimize( ).
*     Hide Certain Column --------------------------------------------------------------------------------
      TRY.
          lo_column ?= lo_columns->get_column( 'MANDT' ).
        CATCH cx_salv_not_found.
      ENDTRY.
      lo_column->set_visible( value = if_salv_c_bool_sap=>false ).

*     Custom Column Header Text --------------------------------------------------------------------------------

      DATA not_found TYPE REF TO cx_salv_not_found.

*      TRY.
*          lo_column ?= lo_columns->get_column( 'COUNTRYFR' ).
*          lo_column->set_short_text( 'D. Country' ).
*          lo_column->set_medium_text( 'Dep. Country' ).
*          lo_column->set_long_text( 'Departure Country' ).
*        CATCH cx_salv_not_found INTO not_found.
*          " error handling
*      ENDTRY.



      lo_table->display( ).

    CATCH cx_salv_msg.             " cl_salv_table=>factory()
      WRITE: / 'cx_salv_msg exception'.
      STOP.
    CATCH cx_salv_not_found.       " cl_salv_columns_table->get_column()
      WRITE: / 'cx_salv_not_found exception'.
      STOP.
  ENDTRY.
ENDFORM.                    "display_alv
