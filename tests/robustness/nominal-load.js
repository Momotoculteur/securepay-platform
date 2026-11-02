// =============================================================================
// SCÉNARIO k6 - CHARGE NOMINALE (état stable de référence)
// =============================================================================
// Les thresholds traduisent directement les SLO de SecurePay :
//   - disponibilité : 99,5 % de requêtes de paiement réussies
//   - latence       : p95 des paiements < 300 ms
// Un threshold franchi fait sortir k6 en erreur : utilisable comme Quality Gate.
//
// Exécution :
//   k6 run tests/robustness/nominal-load.js
//   BASE_URL=http://api.securepay.local RATE=20 DURATION=5m k6 run tests/robustness/nominal-load.js
// Envoi des métriques vers Prometheus (remote write activé dans observability/) :
//   K6_PROMETHEUS_RW_SERVER_URL=http://prometheus.securepay.local/api/v1/write \
//     k6 run -o experimental-prometheus-rw tests/robustness/nominal-load.js
// =============================================================================
import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://api.securepay.local';

export const options = {
  scenarios: {
    nominal: {
      // Débit constant : la charge ne baisse pas quand l'API ralentit
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.RATE || 20),
      timeUnit: '1s',
      duration: __ENV.DURATION || '5m',
      preAllocatedVUs: 20,
      maxVUs: 100,
    },
  },
  thresholds: {
    // SLO disponibilité : moins de 0,5 % d'échecs
    'http_req_failed{endpoint:payments}': ['rate<0.005'],
    // SLO latence : p95 sous 300 ms
    'http_req_duration{endpoint:payments}': ['p(95)<300'],
    checks: ['rate>0.995'],
  },
};

export default function () {
  const payload = JSON.stringify({
    amount: 49.9,
    currency: 'EUR',
    recipientId: `merchant-${__VU}`,
    description: 'k6 nominal load',
  });

  const res = http.post(`${BASE_URL}/api/payments/process`, payload, {
    headers: { 'Content-Type': 'application/json' },
    tags: { endpoint: 'payments' },
  });

  check(res, {
    'paiement accepté (201)': (r) => r.status === 201,
  });
}
