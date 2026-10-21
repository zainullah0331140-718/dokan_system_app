enum SyncStatus { local, queued, syncing, synced, failed }

enum OutboxAction { create, update, delete }

enum OutboxStatus { pending, inFlight, failed, synced }

enum SaleStatus { held, completed, refunded, partiallyRefunded, voided }

enum SaleSource { pos, imported }

enum PayMethod { cash, card, wallet, credit, cheque, loyalty }

enum PaymentRefType { sale, refund, purchase }

enum PaymentStatus { completed, voided, refunded }

enum DiscountType { percent, fixed }

enum DiscountScope { order, product, customer }

enum CurrencySymbolPosition { before, after }

enum StockMovementType {
  initial,
  purchase,
  sale,
  saleReturn,
  adjustment,
  transferIn,
  transferOut,
  purchaseReturn,
}

enum AdjustmentStatus { draft, posted, cancelled }

enum TransferStatus { draft, inTransit, received, cancelled }

enum PurchaseStatus {
  draft,
  ordered,
  partiallyReceived,
  received,
  returned,
  cancelled,
}

enum ShiftStatus { open, closed }

enum ShiftTxType { cashIn, cashOut, payout, refundPayout }

enum PrinterConnection { bluetooth, network, usb }

enum PrinterRole { receipt, kitchen, label }

enum PrinterJobStatus { queued, printing, done, failed }

enum BackupTrigger { manual, scheduled }
