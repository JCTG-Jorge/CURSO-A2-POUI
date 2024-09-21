import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { PoDynamicFormField } from '@po-ui/ng-components';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { Pedido } from '../models/pedido';

@Injectable({
  providedIn: 'root'
})
export class PedidoService {

  API = environment.apiUrl

  constructor(private http: HttpClient) {
  }

  getPedido(id: number):  Observable<Pedido>{
    let url = this.API +  `wscurso/v1/poPedido/${id}`
    return this.http.get<any>(url)
  }

  lastPedido(): Observable<any>{
    let url = this.API +  `wscurso/v1/poPedido/lastPedido`
    return this.http.get<any>(url)
  }

  apiService(){

    return this.API +  'wscurso/v1/poPedido'
  }
  apiZoomFornecedor(){

    return this.API +  'cie/v1/zoomFornecedor'
  }
  apiZoomProduto(){

    return this.API +  'cie/v1/buscaItem'
  }

  alterarPedido(payload: Pedido){
    let url = this.API +  `wscurso/v1/poPedido`
    return this.http.put<any>(url, payload )


  }

  adicionarPedido(payload: Pedido){
    let url = this.API +  `wscurso/v1/poPedido`
    return this.http.post<any>(url, payload )


  }
  adicionarItemPedido(payload: any){
    let url = this.API +  `wscurso/v1/poItemPedido`
    return this.http.post<any>(url, payload )


  }
  updateItemPedido(payload: any){
    let url = this.API +  `wscurso/v1/poItemPedido`
    return this.http.put<any>(url, payload )


  }

  deleteItemPedido(id: string){
    let url = this.API +  `wscurso/v1/poItemPedido/${id}`
    return this.http.delete<any>(url )


  }

  fieldsFormNew(): Array<PoDynamicFormField>{

    return [
      { property: 'nrPedido',label: 'Nr Pedido', key: true,  disabled: true, type: 'number',
        gridColumns: 2
       },
      {property: 'codFornecedor',
        label: 'Fornecedor',
        searchService:  this.apiZoomFornecedor(),
        columns: [
          {property: 'codEmitente', label: 'Fornecedor'},
          {property: 'nome', label: 'Nome'},
          {property: 'cgc', label: 'CNPJ'}
        ],
        format: ['codEmitente', 'nome'],
        fieldLabel: 'codEmitente',
        fieldValue: 'codEmitente',
        gridColumns: 10,
        required: true

      },

      { property: 'dataPedido', label: 'Data Pedido', type: 'date',  gridColumns: 4, required: true   },
      { property: 'narrativa', label: 'Narrativa',  gridColumns: 12, maxLength: 200, rows: 4 , required: true, },


    ]
  }

  listaItensPedido(nrPedido: number): Observable<any>{

     let url = this.API +  `wscurso/v1/poItemPedido`
     let params = new HttpParams()
     params = params.append('nrPedido', nrPedido)

     return this.http.get<any>(url, {params})

  }
}
