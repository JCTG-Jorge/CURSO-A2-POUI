import { Component, OnInit, ViewChild } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { PoButtonModule, PoDividerModule, PoFieldModule, PoInfoModule, PoModalComponent, PoModalModule, PoNotificationService, PoPageModule } from '@po-ui/ng-components';
import { PoPageDynamicTableActions, PoPageDynamicTableCustomTableAction, PoPageDynamicTableModule } from '@po-ui/ng-templates';
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
    PoFieldModule
  ],
  templateUrl: './page-list.component.html',
  styleUrl: './page-list.component.css'
})
export class PageListComponent implements OnInit {
  @ViewChild("modalDetail", { static: true }) poModalDetail!: PoModalComponent;


  fields: Array<any> = [
    { property: 'nrPedido',label: 'Nr Pedido', key: true,  filter: true,  },
    { property: 'codFornecedor', label: 'Fornecedor', filter: true, gridColumns: 6 },
    { property: 'dataPedido', label: 'Data Pedido', type: 'date', filter: true, gridColumns: 6,  sortable: false },
    { property: 'narrativa', label: 'Narrativa', filter: false, gridColumns: 6 },



  ];

  readonly actions: PoPageDynamicTableActions = {
    new: 'new',
    remove: true,
    removeAll: false
  };


  tableCustomActions: Array<PoPageDynamicTableCustomTableAction> = [
    {
      label: 'Details',
      action: this.detalhe.bind(this),
      icon: 'ph ph-notepad'
    },
    {
      label: 'Editar',
      action: this.editar.bind(this),

      icon: 'ph ph-pencil'
    }
  ];

  nrPedido: number = 0
  fornecedor: number = 0
  data: Date = new Date()
  narrativa: string  = ''
  situacao = 0



  constructor(public service: PedidoService,
              private poNotfication: PoNotificationService,
              private router: Router
  ){}
  ngOnInit(): void {



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

  fechar(){

    this.poModalDetail.close()
  }
  confirma(){}
}
