CLASS zcl_rap_billing_util083 DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    " 1. Define Table Types (This fixes the 'ZRAP_BILL_HDR083 ET_ITM is not valid' error)
    TYPES tt_hdr083 TYPE STANDARD TABLE OF zrap_bill_hdr083 WITH EMPTY KEY.
    TYPES tt_itm083 TYPE STANDARD TABLE OF zrap_bill_itm083 WITH EMPTY KEY.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_rap_billing_util083.

    METHODS set_data
      IMPORTING im_hdr TYPE zrap_bill_hdr083 OPTIONAL
                im_itm TYPE zrap_bill_itm083 OPTIONAL.

    METHODS get_data
      EXPORTING et_hdr TYPE tt_hdr083
                et_itm TYPE tt_itm083.

    METHODS cleanup_buffer.

  PRIVATE SECTION.
    CLASS-DATA mo_instance TYPE REF TO zcl_rap_billing_util083.
    DATA gt_hdr_buffer TYPE tt_hdr083.
    DATA gt_itm_buffer TYPE tt_itm083.
ENDCLASS.

CLASS zcl_rap_billing_util083 IMPLEMENTATION.

  METHOD get_instance.
    IF mo_instance IS INITIAL.
      mo_instance = NEW #( ).
    ENDIF.
    ro_instance = mo_instance.
  ENDMETHOD.

  METHOD set_data.
    IF im_hdr IS SUPPLIED.
      " If record exists in buffer, update it; otherwise append
      DELETE gt_hdr_buffer WHERE bill_id = im_hdr-bill_id.
      APPEND im_hdr TO gt_hdr_buffer.
    ENDIF.

    IF im_itm IS SUPPLIED.
      DELETE gt_itm_buffer WHERE bill_id = im_itm-bill_id
                             AND item_pos = im_itm-item_pos.
      APPEND im_itm TO gt_itm_buffer.
    ENDIF.
  ENDMETHOD.

  METHOD get_data.
    et_hdr = gt_hdr_buffer.
    et_itm = gt_itm_buffer.
  ENDMETHOD.

  METHOD cleanup_buffer.
    CLEAR: gt_hdr_buffer, gt_itm_buffer.
  ENDMETHOD.

ENDCLASS.
