import { Component, OnInit, ViewChild } from '@angular/core';
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import {
  PoBreadcrumb,
  PoButtonModule,
  PoContainerModule,
  PoFieldModule,
  PoModalComponent,
  PoModalModule,
  PoPageAction,
  PoPageModule,
  PoTableColumn,
  PoTableModule,
} from '@po-ui/ng-components';
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
    PoFieldModule
  ],
  templateUrl: './list-item.component.html',
  styleUrl: './list-item.component.css',
})
export class ListItemComponent implements OnInit {
  @ViewChild('modalNovo', { static: true }) poModalNovo!: PoModalComponent;


  columns: Array<PoTableColumn> = [
    { property: 'produto', label: 'Produto' },
    { property: 'descricao', label: 'Descrição' },
    { property: 'preco', label: 'Preço', type: 'currency', format: 'BRL' },
    {
      property: 'vlrTotal',
      label: 'Valor Total',
      type: 'currency',
      format: 'BRL',
    },
  ];

  public readonly actionsPage: Array<PoPageAction> = [
    {
      label: 'Adicionar',
      action: this.adiconarItem.bind(this),
      icon: 'ph ph-plus',
    },
    { label: 'Voltar', url: '/' },
  ];
  public readonly breadcrumb: PoBreadcrumb = {
    items: [{ label: 'Pedido', link: '/' }, { label: 'Item do Pedido' }],
  };

  items!: Array<object>;
  nrPedido: number = 0;

  formPedidoItem!: FormGroup

  constructor(
    private service: PedidoService,
    private activateRoute: ActivatedRoute,
    private fb: FormBuilder
  ) {
    this.nrPedido = activateRoute.snapshot.params['id'];
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
  this.service.listaItensPedido(this.nrPedido).subscribe({
    next: (result) => {
      console.log(result);
      this.items = result.items;
    },
  });

}

  adiconarItem() {
    this.poModalNovo.open()
  }
}
