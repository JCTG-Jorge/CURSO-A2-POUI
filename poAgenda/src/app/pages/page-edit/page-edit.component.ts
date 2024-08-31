import { Component } from '@angular/core';
import { PoPageDynamicEditActions, PoPageDynamicEditField, PoPageDynamicEditModule } from '@po-ui/ng-templates';
import { AgendaService } from '../../services/agenda.service';

@Component({
  selector: 'app-page-edit',
  standalone: true,
  imports: [PoPageDynamicEditModule],
  templateUrl: './page-edit.component.html',
  styleUrl: './page-edit.component.css'
})
export class PageEditComponent {

  public readonly fields: Array<PoPageDynamicEditField> = [
    { property: 'id', key: true, visible: true, type: 'number', disabled: true,  gridColumns: 2 , divider: 'Principal'},
    { property: 'nome', label: 'Nome',  gridColumns: 6 , required: true},
    { property: 'telefone', label: 'Telefone',  gridColumns: 4 , divider: 'Dados', },
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

  public readonly actions: PoPageDynamicEditActions = {
    cancel: '/',
    save: '/',

  };
  constructor(public service: AgendaService){}

}
