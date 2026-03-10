@EndUserText.label: 'Consumption - Bill Header 083'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_RAP_BILLHEADER083
  provider contract transactional_query
  as projection on ZI_RAP_BILLHEADER083
{
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.8
    key BillID,
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.8
    CustomerName,
    BillingDate,
    @Semantics.amount.currencyCode: 'Currency'
    TotalAmount,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
    Currency,
    PaymentStatus,
    StatusCriticality,
    InvoiceFile,
    MimeType,
    FileName,
    LastChangedAt,
    _Items : redirected to composition child ZC_RAP_BILLITEM083
}
