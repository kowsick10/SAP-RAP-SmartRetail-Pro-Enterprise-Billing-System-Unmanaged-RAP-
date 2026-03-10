CLASS lhc_BillItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE BillItem.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE BillItem.
    METHODS read FOR READ IMPORTING keys FOR READ BillItem RESULT result.
    METHODS rba_Header FOR READ IMPORTING keys_rba FOR READ BillItem\_Header FULL result_requested RESULT result LINK association_links.

    METHODS CalcSubtotal FOR DETERMINE ON MODIFY IMPORTING keys FOR BillItem~CalcSubtotal.
    METHODS CalcTotalAmount FOR DETERMINE ON MODIFY IMPORTING keys FOR BillItem~CalcTotalAmount.
ENDCLASS.

CLASS lhc_BillItem IMPLEMENTATION.

  METHOD read.
    SELECT * FROM zrap_bill_itm083 FOR ALL ENTRIES IN @keys
      WHERE bill_id = @keys-BillID AND item_pos = @keys-ItemPosition
      INTO TABLE @DATA(lt_items_db).

    LOOP AT lt_items_db INTO DATA(ls_itm).
      INSERT VALUE #(
          %tky = VALUE #( BillID = ls_itm-bill_id ItemPosition = ls_itm-item_pos )
          ProductID     = ls_itm-product_id
          ProductName   = ls_itm-product_name
          Quantity      = ls_itm-quantity
          UnitPrice     = ls_itm-unit_price
          Subtotal      = ls_itm-subtotal
          Currency      = ls_itm-currency
          LastChangedAt = ls_itm-last_changed_at
      ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Header.
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT * FROM zrap_bill_hdr083 WHERE bill_id = @ls_key-BillID INTO TABLE @DATA(lt_headers).

      IF result_requested = abap_true.
        LOOP AT lt_headers INTO DATA(ls_h).
          INSERT VALUE #(
              %tky = VALUE #( BillID = ls_h-bill_id )
              CustomerName = ls_h-customer_name
              BillingDate  = ls_h-billing_date
              TotalAmount  = ls_h-total_amount
              Currency     = ls_h-currency
              PaymentStatus = ls_h-payment_status
          ) INTO TABLE result.
        ENDLOOP.
      ENDIF.

      LOOP AT lt_headers INTO DATA(ls_h_link).
        APPEND VALUE #( source-%tky = ls_key-%tky
                        target-%tky = VALUE #( BillID = ls_h_link-bill_id ) ) TO association_links.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA(lo_buffer) = zcl_rap_billing_util083=>get_instance( ).
    LOOP AT entities INTO DATA(ls_ent).
      lo_buffer->set_data( im_itm = CORRESPONDING #( ls_ent MAPPING FROM ENTITY ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD CalcSubtotal.
    DATA lt_items TYPE TABLE FOR READ RESULT ZI_RAP_BILLHEADER083\\BillItem.

    READ ENTITIES OF ZI_RAP_BILLHEADER083 IN LOCAL MODE
      ENTITY BillItem FIELDS ( Quantity UnitPrice )
      WITH CORRESPONDING #( keys ) RESULT lt_items.

    MODIFY ENTITIES OF ZI_RAP_BILLHEADER083 IN LOCAL MODE
      ENTITY BillItem UPDATE FIELDS ( Subtotal )
      WITH VALUE #( FOR item IN lt_items (
                       %tky     = item-%tky
                       Subtotal = item-Quantity * item-UnitPrice ) ).
  ENDMETHOD.

  METHOD CalcTotalAmount.
    DATA lt_all_items TYPE TABLE FOR READ RESULT ZI_RAP_BILLHEADER083\\BillItem.
    DATA lv_total_sum TYPE p LENGTH 15 DECIMALS 2.

    " To update the Header, we need Header Keys.
    " We get them by following the association from the Items.
    READ ENTITIES OF ZI_RAP_BILLHEADER083 IN LOCAL MODE
      ENTITY BillItem BY \_Header
        FROM CORRESPONDING #( keys )
      LINK DATA(lt_header_links).

    LOOP AT lt_header_links ASSIGNING FIELD-SYMBOL(<ls_link>).
      " 1. Read all items belonging to this specific Header
      READ ENTITIES OF ZI_RAP_BILLHEADER083 IN LOCAL MODE
        ENTITY BillHeader BY \_Items FIELDS ( Subtotal )
        WITH VALUE #( ( %tky = <ls_link>-target-%tky ) ) RESULT lt_all_items.

      CLEAR lv_total_sum.
      LOOP AT lt_all_items INTO DATA(ls_sum_item).
        lv_total_sum = lv_total_sum + ls_sum_item-Subtotal.
      ENDLOOP.

      " 2. Update the Parent Header with the correctly typed Header Key
      MODIFY ENTITIES OF ZI_RAP_BILLHEADER083 IN LOCAL MODE
        ENTITY BillHeader UPDATE FIELDS ( TotalAmount )
        WITH VALUE #( ( %tky        = <ls_link>-target-%tky
                        TotalAmount = lv_total_sum ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

ENDCLASS.
