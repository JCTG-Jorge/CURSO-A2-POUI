import { Component } from '@angular/core';
import { PoPageDynamicTableActions, PoPageDynamicTableFilters, PoPageDynamicTableModule } from '@po-ui/ng-templates';
import { AgendaService } from '../../services/agenda.service';

@Component({
  selector: 'app-page-list',
  standalone: true,
  imports: [
    PoPageDynamicTableModule
  ],
  templateUrl: './page-list.component.html',
  styleUrl: './page-list.component.css'
})
export class PageListComponent {


  fields: Array<PoPageDynamicTableFilters> = [
    { property: 'id', key: true, visible: true, filter: true, gridColumns: 6},
    { property: 'nome', label: 'Nome',  gridColumns: 12 , filter: true},
    { property: 'telefone', label: 'Telefone',  gridColumns: 6 },
    { property: 'dtCriacao', label: 'Data', type: 'date',  gridColumns: 6 },
    { property: 'ativo', label: 'Ativo', type: 'boolean',  gridColumns: 6 },

      {
        property: 'situacao',
        label: 'Situação',
        type: 'label',
        labels: [
          { value: 1, color: 'blue', label: 'Pendente' },
          { value: 2,  color: 'red', label: 'Suspenso' },
          { value: 3, color: ' #228B22', label: 'Liberado' },

        ]
      }
  ];

  readonly actions: PoPageDynamicTableActions = {
    new: 'new',
    detail: 'detail/:id',
    edit: 'edit/:id',
    remove: true,

  };



  constructor(public service: AgendaService){}


  acao(){

  }



}
