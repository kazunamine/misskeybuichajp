export type BuichaService = {
	name: string;
	product: string;
	url: string;
	icon: string;
	description: string;
};

const iconBase = 'https://apps.buicha.jp/images/appicons/';

export const publicServices: BuichaService[] = [
	{
		name: 'ぶいちゃプロフ',
		product: 'Linkstack',
		url: 'https://buicha.jp/',
		icon: `${iconBase}buichajp.png`,
		description: 'VRChatter向けのプロフィール・リンク集ページを作成できます。',
	},
	{
		name: 'ぶいちゃライブ',
		product: 'MediaMTX',
		url: 'https://live.buicha.jp/',
		icon: `${iconBase}live.png`,
		description: 'VRChatのワールドなどで使えるライブ配信用の映像サーバーです。',
	},
	{
		name: 'ぶいちゃすきー',
		product: 'Misskey',
		url: 'https://misskey.buicha.jp/',
		icon: `${iconBase}misskey.png`,
		description: 'VRChatterが集まるMisskeyのSNSサーバーです。',
	},
	{
		name: 'ぶいちゃリンク',
		product: 'Kutt',
		url: 'https://link.buicha.jp/',
		icon: `${iconBase}link.png`,
		description: '長いURLを短く共有できるURL短縮サービスです。',
	},
	{
		name: 'ぶいちゃ便！',
		product: 'Send',
		url: 'https://send.buicha.jp/',
		icon: `${iconBase}send.png`,
		description: '暗号化されたファイルを期限付きリンクで手軽に送れます。',
	},
	{
		name: 'ぶいちゃクラフト',
		product: 'Minecraft',
		url: 'https://minecraft.buicha.jp/',
		icon: `${iconBase}minecraft.png`,
		description: 'みんなで遊べるMinecraftのマルチプレイサーバーです。',
	},
];

export const inviteOnlyServices: BuichaService[] = [
	{
		name: 'ぶいちゃフォト',
		product: 'immich',
		url: 'https://photos.buicha.jp/',
		icon: `${iconBase}photos.png`,
		description: 'VRChatの写真を自動同期して整理できる写真管理サービスです。',
	},
	{
		name: 'ぶいちゃストレージ',
		product: 'MinIO',
		url: 'https://storage.buicha.jp/',
		icon: `${iconBase}storage.png`,
		description: 'ファイルを保存・共有できるS3互換のオブジェクトストレージです。',
	},
];

export const statusUrl = 'https://status.buicha.jp/';
export const portalUrl = 'https://apps.buicha.jp/';
