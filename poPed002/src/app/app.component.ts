import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { Router, RouterOutlet } from '@angular/router';

import {
  PoMenuItem,
  PoMenuModule,
  PoPageModule,
  PoToolbarModule,
} from '@po-ui/ng-components';
import { RelatorioComponent } from './pages/relatorio/relatorio.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    CommonModule,
    RouterOutlet,
    PoToolbarModule,
    PoMenuModule,
    PoPageModule,
    RelatorioComponent
  ],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {
  readonly menus: Array<PoMenuItem> = [
    { label: 'Home', link: '/' ,  shortLabel:'Home',  icon: 'ph ph-monitor',},
    { label: 'Relatório', shortLabel: 'Relatóro' , action: this.onClickRelatorio.bind(this) , icon: 'ph ph-image-align-left',},
  ];

  menuItemSelected: string = 'Home'
  constructor(private router: Router){}

  private onClickRelatorio(menu: PoMenuItem) {
    this.router.navigateByUrl('/relatorio')
   //this.menuItemSelected = menu.label

  }
}
