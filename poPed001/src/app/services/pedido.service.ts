import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
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

  apiService(){

    return this.API +  'wscurso/v1/poPedido'
  }
  apiZoomFornecedor(){

    return this.API +  'cie/v1/zoomFornecedor'
  }

  alterarPedido(payload: Pedido){
    let url = this.API +  `wscurso/v1/poPedido`
    return this.http.put<any>(url, payload )


  }
}
