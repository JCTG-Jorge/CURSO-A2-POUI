import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment';


@Injectable({
  providedIn: 'root'
})
export class RelatorioService {

 private API = environment.apiUrl
  constructor(private http: HttpClient) { }

  imprimir(payload: any){

    let url = this.API + 'wscurso/v1/esce0500ws'
    return this.http.post(url, payload)
  }

  downlaodArquivos(base64: string, arquivo: string, contentType: string){

     const byteArray = new Uint8Array(
       atob(base64)
        .split("")
        .map(char => char.charCodeAt(0))
     )

     const file = new Blob([byteArray], {type: contentType})
     const fileURL = URL.createObjectURL(file)

     // Contruindo o 'a' Elemento
     let link = document.createElement('a')
        link.download = arquivo
        link.target = "_blank"

      //contruindo a URL

      link.href = fileURL
      document.body.appendChild(link)
      link.click()

      document.body.removeChild(link)

  }
}
