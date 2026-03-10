*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lhc_BillHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR BillHeader RESULT result.

    METHODS create FOR MODIFY IMPORTING entities FOR CREATE BillHeader.
    METHODS earlynumbering_create FOR NUMBERING IMPORTING entities FOR CREATE BillHeader.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE BillHeader.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE BillHeader.

    METHODS read FOR READ IMPORTING keys FOR READ BillHeader RESULT result.
    METHODS rba_Items FOR READ IMPORTING keys_rba FOR READ BillHeader\_Items FULL result_requested RESULT result LINK association_links.
    METHODS cba_Items FOR MODIFY IMPORTING entities_cba FOR CREATE BillHeader\_Items.

    " Declaration for lock method
    METHODS lock FOR LOCK IMPORTING keys FOR LOCK BillHeader.

    METHODS GenerateInvoice FOR MODIFY IMPORTING keys FOR ACTION BillHeader~GenerateInvoice RESULT result.
    METHODS MarkAsPaid FOR MODIFY IMPORTING keys FOR ACTION BillHeader~MarkAsPaid RESULT result.
ENDCLASS.

CLASS lhc_BillHeader IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lv_time) = cl_abap_context_info=>get_system_time( ).
    LOOP AT entities INTO DATA(entity) WHERE BillID IS INITIAL.
      APPEND VALUE #( %cid      = entity-%cid
                      %is_draft = entity-%is_draft
                      BillID    = |B-{ lv_time }| ) TO mapped-billheader.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT bill_id, customer_name, billing_date, total_amount, currency, payment_status, last_changed_at
      FROM zrap_bill_hdr083 FOR ALL ENTRIES IN @keys WHERE bill_id = @keys-BillID
      INTO TABLE @DATA(lt_db).

    result = VALUE #( FOR ls IN lt_db (
        %tky          = VALUE #( BillID = ls-bill_id )
        BillID        = ls-bill_id
        CustomerName  = ls-customer_name
        BillingDate   = ls-billing_date
        TotalAmount   = ls-total_amount
        Currency      = ls-currency
        PaymentStatus = ls-payment_status
        LastChangedAt = ls-last_changed_at ) ).
  ENDMETHOD.

  METHOD rba_Items.
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT * FROM zrap_bill_itm083 WHERE bill_id = @ls_key-BillID INTO TABLE @DATA(lt_items).

      IF result_requested = abap_true.
        LOOP AT lt_items INTO DATA(ls_item).
           INSERT VALUE #(
             %tky = VALUE #( BillID = ls_item-bill_id ItemPosition = ls_item-item_pos )
             ProductID = ls_item-product_id
             Quantity = ls_item-quantity
             UnitPrice = ls_item-unit_price
             Subtotal = ls_item-subtotal
             Currency = ls_item-currency
           ) INTO TABLE result.
        ENDLOOP.
      ENDIF.

      LOOP AT lt_items INTO ls_item.
        APPEND VALUE #( source-%tky = ls_key-%tky
                        target-%tky = VALUE #( BillID = ls_item-bill_id ItemPosition = ls_item-item_pos ) ) TO association_links.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    DATA(lo_buffer) = zcl_rap_billing_util083=>get_instance( ).
    LOOP AT entities INTO DATA(ls_ent).
      lo_buffer->set_data( im_hdr = CORRESPONDING #( ls_ent MAPPING FROM ENTITY ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA(lo_buffer) = zcl_rap_billing_util083=>get_instance( ).
    LOOP AT entities INTO DATA(ls_ent).
      lo_buffer->set_data( im_hdr = CORRESPONDING #( ls_ent MAPPING FROM ENTITY ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Items.
    DATA(lo_buffer) = zcl_rap_billing_util083=>get_instance( ).
    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        DATA(ls_item) = CORRESPONDING zrap_bill_itm083( ls_target MAPPING FROM ENTITY ).
        ls_item-bill_id = ls_cba-BillID.
        lo_buffer->set_data( im_itm = ls_item ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD GenerateInvoice.
    READ ENTITIES OF ZI_RAP_BILLHEADER083 IN LOCAL MODE
      ENTITY BillHeader ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_bills).

    LOOP AT lt_bills INTO DATA(ls_bill).
      DATA(lv_text) = |Invoice 083 for { ls_bill-CustomerName }\nTotal: { ls_bill-TotalAmount } { ls_bill-Currency }|.

      " FIX: Use cloud-compliant cl_abap_conv_codepage instead of cl_abap_codepage
      DATA(lv_xstring) = cl_abap_conv_codepage=>create_out( )->convert( source = lv_text ).

      MODIFY ENTITIES OF ZI_RAP_BILLHEADER083 IN LOCAL MODE
        ENTITY BillHeader UPDATE FIELDS ( InvoiceFile MimeType FileName )
        WITH VALUE #( ( %tky = ls_bill-%tky InvoiceFile = lv_xstring MimeType = 'text/plain' FileName = |Bill_{ ls_bill-BillID }.txt| ) ).
    ENDLOOP.

    READ ENTITIES OF ZI_RAP_BILLHEADER083 IN LOCAL MODE
      ENTITY BillHeader ALL FIELDS WITH CORRESPONDING #( keys ) RESULT lt_bills.
    result = VALUE #( FOR bill IN lt_bills ( %tky = bill-%tky %param = CORRESPONDING #( bill ) ) ).
  ENDMETHOD.

  METHOD MarkAsPaid.
    MODIFY ENTITIES OF ZI_RAP_BILLHEADER083 IN LOCAL MODE
      ENTITY BillHeader UPDATE FIELDS ( PaymentStatus )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky PaymentStatus = 'Paid' ) ).

    READ ENTITIES OF ZI_RAP_BILLHEADER083 IN LOCAL MODE
      ENTITY BillHeader ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_bills).
    result = VALUE #( FOR bill IN lt_bills ( %tky = bill-%tky %param = CORRESPONDING #( bill ) ) ).
  ENDMETHOD.

  METHOD delete. ENDMETHOD.
  METHOD lock.   ENDMETHOD. " Lock implementation
ENDCLASS.

CLASS lsc_ZI_RAP_BILLHEADER083 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_RAP_BILLHEADER083 IMPLEMENTATION.
  METHOD save.
    zcl_rap_billing_util083=>get_instance( )->get_data( IMPORTING et_hdr = DATA(lt_h) et_itm = DATA(lt_i) ).
    IF lt_h IS NOT INITIAL. MODIFY zrap_bill_hdr083 FROM TABLE @lt_h. ENDIF.
    IF lt_i IS NOT INITIAL. MODIFY zrap_bill_itm083 FROM TABLE @lt_i. ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    zcl_rap_billing_util083=>get_instance( )->cleanup_buffer( ).
  ENDMETHOD.
ENDCLASS.
