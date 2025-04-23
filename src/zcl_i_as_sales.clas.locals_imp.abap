CLASS lhc_Sales DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Sales RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Sales.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Sales.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Sales.

    METHODS read FOR READ
      IMPORTING keys FOR READ Sales RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Sales.

ENDCLASS.

CLASS lhc_Sales IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

  loop at entities ASSIGNING FIELD-SYMBOL(<lf_sales>).

    data(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).
    data(lo_instance) = zcl_as_sales=>get_instance( ).
    data(ls_sales) = CORRESPONDING ztas_sales_un( <lf_sales> ).

    ls_sales-orderid = lo_uuid->create_uuid_x16( ).
    APPEND ls_sales to zcl_as_sales=>gt_sales.

    INSERT value #(
        %cid = <lf_sales>-%cid
        %key = <lf_sales>-%key
        orderid = ls_sales-orderid
    ) into TABLE mapped-sales.

  ENDLOOP.


  ENDMETHOD.

  METHOD update.

  TYPES: tt_sales   TYPE TABLE of ztas_sales_un WITH DEFAULT KEY,
         tt_sales_x TYPE TABLE of zsas_sales_un WITH DEFAULT KEY.

  data(lt_sales) = CORRESPONDING tt_sales( entities MAPPING from entity ).
  data(lt_sales_x) = CORRESPONDING tt_sales_x( entities MAPPING FROM ENTITY USING CONTROL ).

  if lt_sales is not INITIAL.

    SELECT from ztas_sales_un
    FIELDS
        client,
        company,
        customer,
        orderid,
        vendor
    FOR ALL ENTRIES IN @entities
    WHERE orderid = @entities-Orderid
    INTO TABLE @DATA(lt_sales_old).

    zcl_as_sales=>gt_sales = value #( for ls in lt_sales
       LET ls_control_flag = VALUE #(  lt_sales_x[ 1 ] OPTIONAL )
           ls_sales_new = VALUE #(  lt_sales[ orderid = ls-orderid ] OPTIONAL )
           ls_sales_old = VALUE #( lt_sales_old[ orderid = ls-orderid ] OPTIONAL )
       IN ( orderid = COND #( WHEN ls_control_flag-orderid IS NOT INITIAL THEN ls_sales_new-orderid
                               ELSE ls_sales_old-orderid )
            customer = COND #( WHEN ls_control_flag-customer IS NOT INITIAL THEN ls_sales_new-customer
                               ELSE ls_sales_old-customer )
            vendor = COND #( WHEN ls_control_flag-vendor IS NOT INITIAL THEN ls_sales_new-vendor
                               ELSE ls_sales_old-vendor )
            company = COND #( WHEN ls_control_flag-company IS NOT INITIAL THEN ls_sales_new-company
                              ELSE ls_sales_old-company )


        ) ).

     ENDIF.

  ENDMETHOD.

  METHOD delete.
  TYPES: ty_orderid_range TYPE RANGE OF ztas_sales_un-orderid.
  DATA lt_orderid_range TYPE ty_orderid_range.

  LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
    IF <ls_key>-Orderid = 'Orderid'.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = <ls_key>-Orderid
      ) TO lt_orderid_range.
    ENDIF.
  ENDLOOP.


  IF lt_orderid_range IS INITIAL.
    RETURN.

  ENDIF.
  DELETE FROM ztas_sales_un
    WHERE orderid IN @lt_orderid_range.
ENDMETHOD.

 METHOD read.

    SELECT * FROM ztas_sales_un
    FOR ALL ENTRIES IN @keys
    WHERE orderid = @keys-Orderid
    INTO TABLE @DATA(lt_sales).

    result = CORRESPONDING #( lt_sales MAPPING TO ENTITY ).

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_AS_SALES DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_AS_SALES IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

  MODIFY ztas_sales_un from TABLE @zcl_as_sales=>gt_sales.

  CLEAR zcl_as_sales=>gt_sales.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
