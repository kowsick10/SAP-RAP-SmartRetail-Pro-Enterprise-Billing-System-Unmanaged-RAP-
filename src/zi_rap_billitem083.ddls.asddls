@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Bill Item 083'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{ serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }
define view entity ZI_RAP_BILLITEM083
  as select from zrap_bill_itm083
  association to parent ZI_RAP_BILLHEADER083 as _Header on $projection.BillID = _Header.BillID
{
  key bill_id         as BillID,
  key item_pos        as ItemPosition,
      product_id      as ProductID,
      product_name    as ProductName,
      @Semantics.quantity.unitOfMeasure: 'Unit' 
      quantity        as Quantity,
      unit            as Unit, 
      @Semantics.amount.currencyCode: 'Currency'
      unit_price      as UnitPrice,
      @Semantics.amount.currencyCode: 'Currency'
      subtotal        as Subtotal,
      currency        as Currency,
      last_changed_at as LastChangedAt,
      _Header
}
