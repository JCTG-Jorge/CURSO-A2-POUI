import { Routes } from '@angular/router';
import { ListItemComponent } from './pages/list-item/list-item.component';
import { PageEditComponent } from './pages/page-edit/page-edit.component';
import { PageListComponent } from './pages/page-list/page-list.component';

export const routes: Routes = [
  {path: '', redirectTo: '/list', pathMatch: 'full'},
  {path: 'list', component: PageListComponent},
  {path: 'edit/:id', component: PageEditComponent},
  {path: 'lista-item/:id', component: ListItemComponent}


];
