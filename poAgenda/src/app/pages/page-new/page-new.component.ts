import { Component } from '@angular/core';
import { PoDynamicFormField } from '@po-ui/ng-components';
import { PoPageDynamicEditActions, PoPageDynamicEditModule } from '@po-ui/ng-templates';
import { AgendaService } from '../../services/agenda.service';

@Component({
  selector: 'app-page-new',
  standalone: true,
  imports: [
    PoPageDynamicEditModule
  ],
  templateUrl: './page-new.component.html',
  styleUrl: './page-new.component.css'
})
export class PageNewComponent {

  public readonly fields: Array<PoDynamicFormField> = [
    { property: 'id', key: true, visible: true, type: 'number',  gridColumns: 2 , divider: 'Principal'},
    { property: 'nome', label: 'Nome',  gridColumns: 6 },
    { property: 'telefone', label: 'Telefone',  gridColumns: 4 , divider: 'Dados'},
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
    saveNew: 'new'
  };
  constructor(public service: AgendaService){}

}
