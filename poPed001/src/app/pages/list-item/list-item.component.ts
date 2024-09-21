import { Component, OnInit, ViewChild } from '@angular/core';
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import {
  PoBreadcrumb,
  PoButtonModule,
  PoContainerModule,
  PoDynamicModule,
  PoDynamicViewField,
  PoFieldModule,
  PoLoadingModule,
  PoLookupColumn,
  PoModalComponent,
  PoModalModule,
  PoNotificationService,
  PoPageAction,
  PoPageModule,
  PoTableAction,
  PoTableColumn,
  PoTableComponent,
  PoTableModule
} from '@po-ui/ng-components';
import { Produto } from '../../models/produto';
import { ExcelService } from '../../services/excel.service';
import { PedidoService } from '../../services/pedido.service';

@Component({
  selector: 'app-list-item',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    FormsModule,
    PoPageModule,
    PoTableModule,
    PoContainerModule,
    PoButtonModule,
    PoModalModule,
    PoFieldModule,
    PoLoadingModule,
    PoDynamicModule
  ],
  templateUrl: './list-item.component.html',
  styleUrl: './list-item.component.css',
})
export class ListItemComponent implements OnInit {
  @ViewChild('modalNovo', { static: true }) poModalNovo!: PoModalComponent;
  @ViewChild('modalEdit', { static: true }) poModalEdit!: PoModalComponent;
  @ViewChild('modalDetail', { static: true }) poModalDetail!: PoModalComponent;
  @ViewChild(PoTableComponent, { static: true }) poTable!: PoTableComponent;





  columns: Array<PoTableColumn> = [
    { property: 'produto', label: 'Produto' , },
    { property: 'descricao', label: 'Descrição' },
    { property: 'preco', label: 'Preço', type: 'currency', format: 'BRL' },
    {
      property: 'vlrTotal',
      label: 'Valor Total',
      type: 'currency',
      format: 'BRL',
    }

  ];

  public readonly columnsZoom: Array<PoLookupColumn> = [
    { property: 'itCodigo', label: 'Item' },
    { property: 'descricao', label: 'Descrição' }
  ];


  fieldFormat(produto: any) {
    return `${produto.itCodigo} - ${produto.descricao}`;
  }

  public readonly actionsPage: Array<PoPageAction> = [
    {
      label: 'Adicionar',
      action: this.adiconarItem.bind(this),
      icon: 'ph ph-plus',
    },
    { label: 'Voltar', url: '/' },
    { label: 'Exportar', action: this.exportarDados.bind(this)},
  ];

 public readonly actions: Array<PoTableAction> = [
  {
    action: this.editar.bind(this),
    icon: 'ph ph-pencil',
    label: 'Editar',
  },
  { action: this.detalhe.bind(this), icon: 'ph ph-info', label: 'Detalhes' },
  { action: this.remover.bind(this), icon: 'po-icon ph ph-trash', label: 'Excluir', type: 'danger' }
 ]
  public readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Pedido', link: '/' }, { label: 'Item do Pedido' }],
  };

  items!: Array<object>;
  nrPedido: number = 0;

  produto!: Produto
  fieldsProduto: Array<PoDynamicViewField> = [
    {property: 'nrPedido', label: 'Nr Pedido', container: 'Dados do Pedido'},
    {property: 'produto', label: 'Item', container: 'Dados do Item'},
    {property: 'preco', label: 'Preço' , type: 'currency'},
    {property: 'vlrTotal', label: 'Valor Total', type: 'currency',  tag: true , color: '#FF00FF'},

  ]


  formPedidoItem!: FormGroup
  isLoading: boolean = true
  constructor(
    public service: PedidoService,
    private activateRoute: ActivatedRoute,
    private poMsg: PoNotificationService,
    private fb: FormBuilder,
    private excelService: ExcelService
  ) {
    let id = activateRoute.snapshot.params['id']
    this.nrPedido = parseInt(id);
  }

  ngOnInit(): void {

    this.formPedidoItem = this.fb.group({
        nrPedido: [this.nrPedido],
        produto: ['', [Validators.required]],
        preco: [0, [Validators.required]],
        vlrTotal: [0, Validators.required]
    })

    this.carregarDados()

  }

carregarDados(){
  this.isLoading = false
  this.service.listaItensPedido(this.nrPedido).subscribe({
    next: (result) => {
      this.items = result.items;
      this.isLoading = true
    },
    error: err => {this.isLoading = true}
  });

}

editar(item: Produto){

  this.formPedidoItem.patchValue({'nrPedido': item.nrPedido})
  this.formPedidoItem.patchValue({'produto': item.produto})
  this.formPedidoItem.patchValue({'preco': item.preco})
  this.formPedidoItem.patchValue({'vlrTotal': item.vlrTotal})
  this.poModalEdit.open()

}

detalhe(item: Produto){

   this.produto = item

  this.poModalDetail.open()
}

remover(item: Produto){

  this.isLoading = false
  this.service.deleteItemPedido(item.id).subscribe({
    next: result => {
      console.log(result)
      this.poMsg.success('Registro Eliminado com sucesso!')
      this.isLoading = true
      this.poTable.removeItem(item)
    },
    error: err => { this.isLoading = true}
  })

}

  adiconarItem() {
    this.poModalNovo.open()
  }

  cancelar(){

    this.poModalNovo.close()
  }

  confirma(){
    let playload = this.formPedidoItem.value

    this.isLoading = false
    this.service.adicionarItemPedido(playload).subscribe({
      next: result => {

        this.poMsg.success('Registro gravado com sucesso!')
        this.isLoading = true
        this.carregarDados()
        this.poModalNovo.close()
      },
      error: err => {this.isLoading = true },

    })


  }

  confirmaEdit(){

    if(!this.formPedidoItem.valid){
      this.poMsg.error('Exitem campo obrigatório sem preencher!')
      return
    }



    this.isLoading = false
    this.service.updateItemPedido(this.formPedidoItem.value).subscribe({
      next: result => {

        this.poMsg.success('Registro alterado com sucesso!')
        this.isLoading = true
        this.carregarDados()
        this.poModalEdit.close()
      },
      error: err => {
        this.isLoading = true
      }
    })


  }

  cancelarEdit(){
    this.poModalEdit.close()
  }

  exportarDados(){
    this.excelService.exportToExcel(this.items, 'itensDoPedido.xlsx')

  }

}
