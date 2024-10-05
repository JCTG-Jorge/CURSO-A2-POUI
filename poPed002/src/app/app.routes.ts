import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home/home.component';
import { RelatorioComponent } from './pages/relatorio/relatorio.component';

export const routes: Routes = [

  {path: '', redirectTo: '/home', pathMatch: 'full'},
  {path: 'home', component: HomeComponent},
  {path: 'relatorio', component: RelatorioComponent}
];
