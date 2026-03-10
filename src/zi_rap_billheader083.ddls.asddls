@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Bill Header 083'
define root view entity ZI_RAP_BILLHEADER083
  as select from zrap_bill_hdr083
  composition [0..*] of ZI_RAP_BILLITEM083 as _Items
{
  key bill_id         as BillID,
      customer_name   as CustomerName,
      billing_date    as BillingDate,
      @Semantics.amount.currencyCode : 'Currency'
      total_amount    as TotalAmount,
      currency        as Currency,
      payment_status  as PaymentStatus,
      case payment_status
        when 'Paid'  then 3
        when 'Draft' then 1
        else 0
      end             as StatusCriticality,
      @Semantics.largeObject: { mimeType: 'MimeType', fileName: 'FileName', contentDispositionPreference: #ATTACHMENT }
      invoice_file    as InvoiceFile,
      mimetype        as MimeType,
      filename        as FileName,
      last_changed_at as LastChangedAt,
      _Items
}
