export interface Pedido {
  nrPedido: number;
  codFornecedor: number;
  dataPedido?: Date;
  statusPedido?: number;
  narrativa: string;
}
