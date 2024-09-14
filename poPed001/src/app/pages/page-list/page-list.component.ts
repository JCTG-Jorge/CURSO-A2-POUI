import { Component, OnInit, ViewChild } from '@angular/core';
import { FormsModule, NgForm } from '@angular/forms';
import { Router } from '@angular/router';
import { PoButtonModule, PoDividerModule, PoDynamicFormField, PoDynamicModule, PoFieldModule, PoInfoModule, PoLoadingModule, PoModalComponent, PoModalModule, PoNotificationService, PoPageModule } from '@po-ui/ng-components';
import { PoPageDynamicTableActions, PoPageDynamicTableComponent, PoPageDynamicTableCustomAction, PoPageDynamicTableCustomTableAction, PoPageDynamicTableModule } from '@po-ui/ng-templates';
import { Pedido } from '../../models/pedido';
import { PedidoService } from '../../services/pedido.service';

@Component({
  selector: 'app-page-list',
  standalone: true,
  imports: [
    FormsModule,
    PoPageDynamicTableModule,
    PoModalModule,
    PoButtonModule,
    PoPageModule,
    PoInfoModule,
    PoDividerModule,
    PoFieldModule,
    PoDynamicModule,
    PoLoadingModule
  ],
  templateUrl: './page-list.component.html',
  styleUrl: './page-list.component.css'
})
export class PageListComponent implements OnInit {
  @ViewChild("modalDetail", { static: true }) poModalDetail!: PoModalComponent;
  @ViewChild("modalNovo", { static: true }) poModalNovo!: PoModalComponent;
  @ViewChild("formNovo", {static: true}) formNovo!: NgForm
  @ViewChild("dynamicTable", { static: true }) dynamicTable!: PoPageDynamicTableComponent;

  isLoading: boolean = true

  fields: Array<any> = [
    { property: 'statusPedido', label: 'Sit', type: 'subtitle',
      subtitles: [
        { value: 1, color: 'color-07', label: 'Pendente', content: 'P' },
        { value: 2, color: 'color-10', label: 'Completo', content: 'C' },

      ]
    },
    { property: 'nrPedido',label: 'Nr Pedido', key: true,  filter: true,  },
    { property: 'codFornecedor', label: 'Fornecedor', filter: true, gridColumns: 6 },
    { property: 'dataPedido', label: 'Data Pedido', type: 'date', filter: true, gridColumns: 6,  sortable: false },
    { property: 'narrativa', label: 'Narrativa', filter: false, gridColumns: 6 },




  ];

  readonly actions: PoPageDynamicTableActions = {
    remove: true,
    removeAll: false
  };

  actionsPage: Array<PoPageDynamicTableCustomAction> = [

    { label: 'Novo', action: this.novoPedido.bind(this) }

  ]

  tableCustomActions: Array<PoPageDynamicTableCustomTableAction> = [
    {
      label: 'Details',
      action: this.detalhe.bind(this),
      icon: 'ph ph-notepad'
    },
    {
      label: 'Editar',
      action: this.editar.bind(this),

      icon: 'ph-fill ph-pencil'
    },
    {
      label: 'Lista Itens',
      action: this.listaDeItens.bind(this),
      icon: 'ph-fill ph-address-book-tabs'
    },
  ];

  nrPedido: number = 0
  fornecedor: number = 0
  data: Date = new Date()
  narrativa: string  = ''
  situacao = 0

  pedido!: Pedido

  fields_new!: Array<PoDynamicFormField>


  constructor(public service: PedidoService,
              private poNotfication: PoNotificationService,
              private router: Router
  ){}
  ngOnInit(): void {

    this.fields_new = this.service.fieldsFormNew()


  }


  detalhe(pedido: Pedido){

    this.nrPedido = pedido.nrPedido
    this.fornecedor = pedido.codFornecedor
    this.data = pedido.dataPedido!
    this.narrativa = pedido.narrativa
    this.situacao = pedido.statusPedido!


    this.poModalDetail.open()

  }
  editar(pedido: Pedido){
    this.router.navigateByUrl(`/edit/${pedido.nrPedido}`)
  }

  listaDeItens(pedido: Pedido){
    this.router.navigateByUrl(`/lista-item/${pedido.nrPedido}`)

  }

  fechar(){

    this.poModalDetail.close()
  }


  novoPedido(){

    this.isLoading = false
    this.service.lastPedido().subscribe({
      next: resposta => {
        let numPedido = resposta.lastPedido + 1

         this.isLoading = true
         this.pedido = {
          nrPedido: numPedido,
          codFornecedor: 0,
          dataPedido: new Date(),
          statusPedido: 1,
          narrativa: ''
        }
      },
      error: err => { this.isLoading = true}
    })



    this.poModalNovo.open()
  }
  fecharNovo(){
    this.poModalNovo.close()
  }

  salvar(){

    this.isLoading = false

    this.service.adicionarPedido(this.pedido).subscribe({
      next: result => {
        console.log(result)
        this.isLoading = true
        this.poNotfication.success('Registro gravado com sucesso!')
        this.formNovo.form.reset()
        this.fecharNovo()
        this.atualizaTable()
      },
      error: err => { this.isLoading = true}
    })
  }

  atualizaTable(){
    this.dynamicTable.updateDataTable()
  }

}
