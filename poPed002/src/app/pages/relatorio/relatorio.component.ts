import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { PoButtonModule, PoContainerModule, PoFieldModule, PoLoadingModule, PoNotificationService, PoPageModule, PoTabsModule } from '@po-ui/ng-components';
import { RelatorioService } from '../../services/relatorio.service';

@Component({
  selector: 'app-relatorio',
  standalone: true,
  imports: [
    FormsModule,
    PoPageModule,
    PoTabsModule,
    PoFieldModule,
    PoContainerModule,
    PoButtonModule,
    PoLoadingModule
   ],

  templateUrl: './relatorio.component.html',
  styleUrl: './relatorio.component.css'
})
export class RelatorioComponent {

  execucao: number = 1
  estabIni: string = ''
  estabFim: string = 'ZZZZZ'
  itCodigoIni: string = ''
  itCodigoFim: string = 'ZZZZZZZZZZZZZZZZ'
  dtTransIni: Date = new Date()
  dtTransFim: Date = new Date()

  isLoading: boolean = true
  constructor(private serviceRelatorio: RelatorioService,
              private poNotification: PoNotificationService
  ){}

  executar(){

    const payload = {

      codEstabelIni: this.estabIni,
      codEstabelFim: this.estabFim,
      dataIni: this.dtTransIni,
      dataFim: this.dtTransFim,
      itCodigoIni: this.itCodigoIni,
      itCodigoFim: this.itCodigoFim
    }
    this.isLoading = false

    this.serviceRelatorio.imprimir(payload).subscribe({
      next: (reponse: any) => {
         console.log(reponse)
         let contentType = 'application/xml'

         this.serviceRelatorio.downlaodArquivos(
            reponse.pRelatorio,
            reponse.pNomeArquivo,
            contentType

         )
         this.isLoading = true
         this.poNotification.success('Relatório gerado com sucesso, verifique sua pasta de downloads!')
      },
      error: err => {
        this.isLoading = true
      }
    })




  }

}
