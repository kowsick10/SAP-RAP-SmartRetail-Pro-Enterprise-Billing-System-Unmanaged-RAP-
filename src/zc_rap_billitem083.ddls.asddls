@EndUserText.label: 'Consumption - Bill Item 083'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true

define view entity ZC_RAP_BILLITEM083
  as projection on ZI_RAP_BILLITEM083
{
    key BillID,
    key ItemPosition,
    
    @Search.defaultSearchElement: true
    ProductID,
    ProductName,
    
    @Semantics.quantity.unitOfMeasure: 'Unit' /* <-- Added explicit link */
    Quantity,
    
    Unit,
    
    @Semantics.amount.currencyCode: 'Currency'
    UnitPrice,
    
    @Semantics.amount.currencyCode: 'Currency'
    Subtotal,
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
    Currency,
    LastChangedAt,
    
    _Header : redirected to parent ZC_RAP_BILLHEADER083
}
