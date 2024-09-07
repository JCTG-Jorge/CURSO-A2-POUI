import { Component, OnInit, ViewChild } from '@angular/core';
import { FormsModule, NgForm } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { PoFieldModule, PoLoadingModule, PoLookupColumn, PoNotificationService, PoPageModule } from '@po-ui/ng-components';
import { PedidoService } from '../../services/pedido.service';

@Component({
  selector: 'app-page-edit',
  standalone: true,
  imports: [
    FormsModule,
    PoPageModule,
    PoFieldModule,
    PoLoadingModule

  ],
  templateUrl: './page-edit.component.html',
  styleUrl: './page-edit.component.css'
})
export class PageEditComponent implements OnInit{
  @ViewChild('formEditPedido', { static: true }) formEditPedido!: NgForm;

  nrPedido = 0


  fornecedor: number = 0
  data: Date = new Date()
  narrativa: string  = ''
  situacao = 0

  isLoding: boolean = true

  fieldFormat(emitente: any) {
    return `${emitente.codEmitente} - ${emitente.nome}`;
  }

  public readonly columnsZoom: Array<PoLookupColumn> = [
    { property: 'codEmitente', label: 'Codigo' },
    { property: 'nome', label: 'Nome' },
    { property: 'cgc', label: 'CNPJ' }
  ];

  constructor(private activateRoute: ActivatedRoute,
              public service: PedidoService,
              private poNotification: PoNotificationService,
              private router: Router
  ){

    this.nrPedido = activateRoute.snapshot.params['id']

  }
  ngOnInit(): void {

    this.isLoding = false

    this.service.getPedido(this.nrPedido).subscribe({
      next: response => {

        this.nrPedido = response.nrPedido
        this.fornecedor = response.codFornecedor
        this.data = response.dataPedido!
        this.narrativa = response.narrativa
        this.situacao = response.statusPedido!
        this.isLoding = true
      },
      error: err => {
        this.isLoding = true
      }
    })




  }


  cancelar(){
   this.router.navigateByUrl('/')

  }
  salvar(){

    let payload = {
      nrPedido: this.nrPedido,
      codFornecedor: this.fornecedor,
      dataPedido: this.data,
      statusPedido: this.situacao,
      narrativa: this.narrativa
    }

    this.isLoding = false
    this.service.alterarPedido(payload).subscribe({
      next: dados => {
        console.log(dados)
        this.isLoding = true
        this.poNotification.success('Registro alterado com sucesso!')
      }
      , error : err => {
        this.isLoding = true

      }

    })
  }

}
