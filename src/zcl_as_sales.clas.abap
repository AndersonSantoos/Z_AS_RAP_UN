CLASS zcl_as_sales DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA: go_instance TYPE REF TO zcl_as_sales,
                gt_sales TYPE TABLE of ztas_sales_un.

    CLASS-METHODS get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_as_sales.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_as_sales IMPLEMENTATION.

  METHOD get_instance.

    go_instance = ro_instance = COND #(
        when go_instance is BOUND then go_instance
        ELSE NEW #(  )
     ).

  ENDMETHOD.

ENDCLASS.
