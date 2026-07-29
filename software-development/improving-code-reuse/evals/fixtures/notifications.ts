// Three notification senders with genuinely duplicated retry+log scaffolding.
export async function sendEmail(to: string, body: string) {
  for (let i = 0; i < 3; i++) {
    try { return await post('/api/email', { to, body }); }
    catch (e) { if (i === 2) { console.error('email failed', e); throw e; } }
  }
}

export async function sendSms(to: string, body: string) {
  for (let i = 0; i < 3; i++) {
    try { return await post('/api/sms', { to, body }); }
    catch (e) { if (i === 2) { console.error('sms failed', e); throw e; } }
  }
}

export async function sendPush(to: string, body: string) {
  for (let i = 0; i < 3; i++) {
    try { return await post('/api/push', { to, body }); }
    catch (e) { if (i === 2) { console.error('push failed', e); throw e; } }
  }
}

declare function post(url: string, body: unknown): Promise<unknown>;
