import { Component } from '@angular/core';
import { PoPageDynamicDetailActions, PoPageDynamicDetailField, PoPageDynamicDetailModule } from '@po-ui/ng-templates';
import { AgendaService } from '../../services/agenda.service';

@Component({
  selector: 'app-page-detail',
  standalone: true,
  imports: [
    PoPageDynamicDetailModule
  ],
  templateUrl: './page-detail.component.html',
  styleUrl: './page-detail.component.css'
})
export class PageDetailComponent {


  public readonly actions: PoPageDynamicDetailActions = {
    back: '/',


  };
  public readonly fields: Array<PoPageDynamicDetailField> = [

    { property: 'id', key: true, visible: true, type: 'number',  gridColumns: 2 , divider: 'Principal'},
    { property: 'nome', label: 'Nome',  gridColumns: 6 },
    { property: 'telefone', label: 'Telefone',  gridColumns: 4 , divider: 'Dados', color: 'color-02'},
    { property: 'dtCriacao', label: 'Data', type: 'date',  gridColumns: 6 },
    { property: 'ativo', label: 'Ativo', type: 'boolean', booleanTrue: 'Sim' , booleanFalse: 'Não', gridColumns: 6 },

      {
        property: 'situacao',
        label: 'Situação',
        options: [
          { value: 1,  label: 'Pendente' },
          { value: 2, label: 'Suspenso' },
          { value: 3, label: 'Liberado' },

        ]
      },
  ];



  constructor(public service: AgendaService){}


}
