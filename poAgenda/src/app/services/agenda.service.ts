import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AgendaService {

  private API = environment.apiUrl

  constructor(private http: HttpClient) { }


  apiService(){
    return this.API + 'wscurso/v1/agenda'
  }


}
