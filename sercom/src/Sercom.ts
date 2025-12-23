import ky, { type KyInstance } from 'ky';
import { createHmac } from 'node:crypto';
import { UserLangResponseSchema, LanSettingsResponseSchema, type LanSettingsResponse } from './SercomSchema.ts';

export class Sercom {
  private readonly baseUrl = "http://192.168.1.1";
  private readonly username: string;
  private csrfToken: string;
  private sessionId: string;
  private kyInstance: KyInstance;

  private constructor(username: string, csrfToken: string, sessionId: string) {
    this.username = username;
    this.csrfToken = csrfToken;
    this.sessionId = sessionId;

    this.kyInstance = ky.create({
      prefixUrl: this.baseUrl,
    });
  }

  public static async login(username: string, password: string): Promise<Sercom> {
    const csrfToken = await Sercom.getCsrfToken();
    const encryptionKey = await Sercom.getEncryptionKey(csrfToken);
    const encryptedPassword = Sercom.encryptPassword(password, encryptionKey);
    const sessionId = await Sercom.performLogin(username, encryptedPassword, csrfToken);
    return new Sercom(username, csrfToken, sessionId);
  }

  private static async getCsrfToken(): Promise<string> {
    const response = await ky.get(`http://192.168.1.1/login.html`);

    const text = await response.text();
    const regex = /var csrf_token = '([A-Z0-9]+)';/;
    const match = text.match(regex);

    if (!match || !match[1]) {
      throw new Error('CSRF token not found in login page');
    }

    return match[1];
  }

  private static async getEncryptionKey(csrfToken: string): Promise<string> {
    const response = await ky.get(`http://192.168.1.1/data/user_lang.json`, {
      searchParams: {
        csrf_token: csrfToken,
      },
    });

    const json = await response.json();
    const data = UserLangResponseSchema.parse(json);
    return data[0].encryption_key;
  }

  private static encryptPassword(password: string, encryptionKey: string): string {
    // Step 1: HMAC-SHA256 with fixed key
    const hash1 = createHmac('sha256', '$1$SERCOMM$')
      .update(password)
      .digest('hex');

    // Step 2: HMAC-SHA256 with encryption_key
    const hash2 = createHmac('sha256', encryptionKey)
      .update(hash1)
      .digest('hex');

    return hash2;
  }

  private static async performLogin(
    username: string,
    encryptedPassword: string,
    csrfToken: string
  ): Promise<string> {
    const timestamp = Date.now();

    const response = await ky.post(`http://192.168.1.1/data/login.json`, {
      searchParams: {
        _: timestamp.toString(),
        csrf_token: csrfToken,
      },
      body: new URLSearchParams({
        LoginName: username,
        LoginPWD: encryptedPassword,
      }).toString(),
      credentials: 'include',
    });

    // Extract session_id from Set-Cookie header
    const setCookieHeader = response.headers.get('set-cookie');
    if (!setCookieHeader) {
      throw new Error('No Set-Cookie header in login response');
    }

    const match = setCookieHeader.match(/session_id=([^;]+)/);
    if (!match || !match[1]) {
      throw new Error('Session ID not found in Set-Cookie header');
    }

    return match[1];
  }

  // Public operation methods

  public async getLanSettings(): Promise<LanSettingsResponse> {
    const timestamp = Date.now();

    const response = await this.kyInstance.get('data/settings_lan.json', {
      searchParams: {
        _: timestamp.toString(),
        csrf_token: this.csrfToken,
      },
      headers: {
        'cookie': `session_id=${this.sessionId}`,
      },
      credentials: 'include',
    });

    const json = await response.json();
    return LanSettingsResponseSchema.parse(json);
  }
}
