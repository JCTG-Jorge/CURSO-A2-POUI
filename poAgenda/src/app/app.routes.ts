import { Routes } from '@angular/router';
import { PageDetailComponent } from './pages/page-detail/page-detail.component';
import { PageEditComponent } from './pages/page-edit/page-edit.component';
import { PageListComponent } from './pages/page-list/page-list.component';
import { PageNewComponent } from './pages/page-new/page-new.component';

export const routes: Routes = [
  {path: '', redirectTo: '/list', pathMatch: 'full'},
  {path: 'list', component: PageListComponent},
  {path: 'new', component: PageNewComponent},
  {path: 'detail/:id', component: PageDetailComponent},
  {path: 'edit/:id', component: PageEditComponent}

];
