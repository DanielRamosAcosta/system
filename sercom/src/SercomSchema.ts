import { z } from 'zod';

export const UserLangResponseSchema = z.tuple([
  z.object({ encryption_key: z.string() }).strict(),
  z.object({ salt: z.string() }).strict(),
  z.object({ lang_code: z.string() }).strict(),
  z.object({ ipv6_status: z.string() }).strict(),
  z.object({ ipv6_configuration: z.string() }).strict(),
  z.object({ fw_version: z.string() }).strict(),
  z.object({ wan_ip4_addr: z.string() }).strict(),
  z.object({ wan_ip6_addr: z.string() }).strict(),
  z.object({ delay_time: z.string() }).strict(),
  z.object({ trying_times: z.string() }).strict(),
]);

export type UserLangResponse = z.infer<typeof UserLangResponseSchema>;

export const LanSettingsResponseSchema = z.tuple([
  z.object({ LanIP: z.string() }).strict(),
  z.object({ LanSubnetMask: z.string() }).strict(),
  z.object({ LanHostName: z.string() }).strict(),
  z.object({ LanDHCP: z.string() }).strict(),
  z.object({ LanDHCPStartIP: z.string() }).strict(),
  z.object({ LanDHCPEndIP: z.string() }).strict(),
  z.object({ LanDHCPLeaseTime: z.string() }).strict(),
  z.object({ LanDHCPDomainName: z.string() }).strict(),
  z.object({ LanDHCPOption66: z.string() }).strict(),
  z.object({ LanDHCPOption67: z.string() }).strict(),
  z.object({ LanDHCPOption160: z.string() }).strict(),
  z.object({ lanHostName_guest: z.string() }).strict(),
  z.object({ LanDHCP_guest: z.string() }).strict(),
  z.object({ LanIP_guest: z.string() }).strict(),
  z.object({ LanSubnetMask_guest: z.string() }).strict(),
  z.object({ LanDHCPStartIP_guest: z.string() }).strict(),
  z.object({ LanDHCPEndIP_guest: z.string() }).strict(),
  z.object({ LanDHCPLeaseTime_guest: z.string() }).strict(),
  z.object({ LanDHCPDomainName_guest: z.string() }).strict(),
  z.object({ ip6_dhcp_server: z.string() }).strict(),
  z.object({ ip6_router_advertisement: z.string() }).strict(),
  z.object({ LanDNSServer: z.string() }).strict(),
  z.object({ LanDNSServer_guest: z.string() }).strict(),
  z.object({ LanDNSProxy: z.string() }).strict(),
  z.object({ LanDNSProxy_guest: z.string() }).strict(),
]);

export type LanSettingsResponse = z.infer<typeof LanSettingsResponseSchema>;
