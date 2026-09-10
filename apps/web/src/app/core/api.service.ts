import { Injectable } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class ApiService {
  readonly coreApiUrl = 'http://localhost:8080/api/v1';
  readonly intelligenceApiUrl = 'http://localhost:8000/api/v1';
}
