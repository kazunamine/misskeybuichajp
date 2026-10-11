<!--
SPDX-FileCopyrightText: syuilo and misskey-project
SPDX-License-Identifier: AGPL-3.0-only
-->

<template>
<div v-if="meta" :class="$style.root">
	<!-- HERO -->
	<section :class="$style.hero">
		<svg :class="$style.heroArt" :viewBox="`0 0 ${ART_W} ${ART_H}`" preserveAspectRatio="xMidYMid slice" aria-hidden="true" focusable="false">
			<defs>
				<symbol id="bkg-ring" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="4.5"/></symbol>
				<symbol id="bkg-x" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 5L19 19M19 5L5 19"/></symbol>
				<symbol id="bkg-sq" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="5" y="5" width="14" height="14"/></symbol>
				<symbol id="bkg-plus" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 4V20M4 12H20"/></symbol>
				<symbol id="bkg-dot" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="3"/></symbol>
				<symbol id="bkg-slash" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M7 20L17 4"/></symbol>
			</defs>

			<!-- A: glyph lattice -->
			<g>
				<use
					v-for="g in glyphs"
					:key="g.key"
					:href="`#bkg-${g.kind}`"
					:x="g.x"
					:y="g.y"
					width="24"
					height="24"
					:opacity="g.o"
					:class="g.blink ? $style.blink : undefined"
						:style="g.blink ? { '--o': g.o } : undefined"
				/>
			</g>
			<!-- A: solid lime blocks on the grid -->
			<g :class="$style.artLime">
				<rect v-for="(b, i) in blocks" :key="i" :x="b.c * ART_CELL" :y="b.r * ART_CELL" :width="b.w * ART_CELL" :height="b.h * ART_CELL"/>
			</g>

			<!-- B: chamfered octagon track -->
			<polygon :points="TRACK" :class="$style.trackEdge"/>
			<polygon :points="TRACK" :class="$style.trackBand"/>
			<polygon :points="TRACK_INNER" :class="$style.trackLine"/>

			<!-- C: diagonal lines, dots, crosshairs -->
			<g :class="$style.artLine">
				<path d="M560 40L1060 540M1100 0L1600 500"/>
				<g v-for="(c, i) in crosshairs" :key="i" :transform="`translate(${c.x} ${c.y})`">
					<circle r="22"/>
					<path d="M-44 0H44M0 -44V44"/>
				</g>
			</g>
			<g :class="$style.artDots">
				<circle v-for="(d, i) in dots" :key="i" :cx="d.x" :cy="d.y" r="7"/>
			</g>

			<!-- D: mono labels -->
			<g :class="$style.artText">
				<text x="60" y="150">№.01</text>
				<text x="1052" y="706">© 2026</text>
				<text x="1572" y="120" transform="rotate(90 1572 120)">MISSKEY.BUICHA.JP</text>
			</g>
		</svg>

		<!-- E: liquid glass panel -->
		<div :class="[$style.glassPanel, $style.mono]" aria-hidden="true">
			<span :class="$style.panelNo">№.01</span>
			<span>MISSKEY.BUICHA.JP</span>
			<span>35.6895° N, 139.6917° E</span>
			<span>© 2026</span>
		</div>

		<div :class="$style.heroTop">
			<div :class="$style.brand">
				<img :src="meta.iconUrl || '/favicon.ico'" alt="" :class="$style.brandIcon"/>
				<span :class="$style.brandName">{{ meta.name || 'ぶいちゃすきー' }}</span>
			</div>
			<div :class="$style.heroTopRight">
				<span :class="[$style.glassChip, $style.mono]"><span :class="$style.dot"></span>β TEST / OPEN</span>
				<span :class="[$style.mono, $style.scrollHint]">SCROLL ↓</span>
			</div>
		</div>

		<div :class="$style.heroBottom">
			<div :class="$style.heroText">
				<div :class="[$style.mono, $style.heroLabel]">VRCHATTER'S MISSKEY SERVER — BUICHA.JP</div>
				<h1 :class="$style.heroTitle">ぶいちゃすきー</h1>
				<p :class="$style.heroLead">ぶいちゃ民による<wbr>ぶいちゃ民のための<wbr>ぶいちゃ民のミスキー</p>
				<div v-if="meta.disableRegistration || meta.federation !== 'all'" :class="$style.heroWarn" class="_gaps_s">
					<MkInfo v-if="meta.disableRegistration" warn>{{ i18n.ts.invitationRequiredToRegister }}</MkInfo>
					<MkInfo v-if="meta.federation === 'specified'" warn>{{ i18n.ts.federationSpecified }}</MkInfo>
					<MkInfo v-else-if="meta.federation === 'none'" warn>{{ i18n.ts.federationDisabled }}</MkInfo>
				</div>
			</div>
			<div :class="$style.heroCta">
				<button type="button" :class="[$style.pill, $style.pillGlass]" data-cy-signin @click="signin()">{{ i18n.ts.login }}</button>
				<button type="button" :class="[$style.pill, $style.pillLime]" data-cy-signup @click="signup()">{{ i18n.ts.joinThisServer }} <span :class="$style.arrow">→</span></button>
			</div>
		</div>
	</section>

	<!-- 01 ABOUT -->
	<section :class="$style.section">
		<div :class="$style.inner">
			<div :class="[$style.mono, $style.label]">01 / ABOUT MISSKEY</div>
			<h2 :class="$style.h2">Misskey ってなに？</h2>
			<ol :class="$style.list">
				<li :class="$style.listItem">
					<span :class="[$style.mono, $style.num]">01</span>
					<span :class="[$style.mono, $style.itemKey]">DECENTRALIZED</span>
					<span :class="$style.itemTitle">分散型SNS</span>
					<span :class="$style.itemText">Fediverse に参加する、オープンソースのSNSです。サーバーごとに運営され、サーバーを越えて交流できます。</span>
				</li>
				<li :class="$style.listItem">
					<span :class="[$style.mono, $style.num]">02</span>
					<span :class="[$style.mono, $style.itemKey]">NOTES</span>
					<span :class="$style.itemTitle">ノート</span>
					<span :class="$style.itemText">短い文章や画像を「ノート」として投稿して、気軽に日々のことをシェアできます。</span>
				</li>
				<li :class="$style.listItem">
					<span :class="[$style.mono, $style.num]">03</span>
					<span :class="[$style.mono, $style.itemKey]">REACTION / MFM</span>
					<span :class="$style.itemTitle">リアクションと MFM</span>
					<span :class="$style.itemText">好きな絵文字でリアクション。MFM を使えば文字を動かしたり装飾したりできます。</span>
				</li>
				<li :class="$style.listItem">
					<span :class="[$style.mono, $style.num]">04</span>
					<span :class="[$style.mono, $style.itemKey]">FEDERATION</span>
					<span :class="$style.itemTitle">他サーバーとつながる</span>
					<span :class="$style.itemText">他のMisskeyサーバーやMastodonなどのユーザーをフォローして、タイムラインで楽しめます。</span>
				</li>
			</ol>
		</div>
	</section>

	<!-- 02 VRCHATTERS -->
	<section :class="$style.section">
		<div :class="$style.inner">
			<div :class="[$style.mono, $style.label]">02 / FOR VRCHATTERS</div>
			<h2 :class="$style.h2">VRChatter のための場所</h2>
			<p :class="$style.betaLine"><mark :class="$style.mark">現在 βテスト運用中</mark> 仕様や運用は今後変わることがあります。</p>
			<ul :class="$style.list">
				<li :class="$style.listItem">
					<span :class="[$style.mono, $style.num]">A</span>
					<span :class="[$style.mono, $style.itemKey]">WORLDS</span>
					<span :class="$style.itemTitle">ワールド情報</span>
					<span :class="$style.itemText">フレンドとワールド情報を共有して、次に遊びに行く場所を見つけられます。</span>
				</li>
				<li :class="$style.listItem">
					<span :class="[$style.mono, $style.num]">B</span>
					<span :class="[$style.mono, $style.itemKey]">EVENTS</span>
					<span :class="$style.itemTitle">イベント</span>
					<span :class="$style.itemText">イベントの告知や参加者の募集を気軽に流せます。</span>
				</li>
				<li :class="$style.listItem">
					<span :class="[$style.mono, $style.num]">C</span>
					<span :class="[$style.mono, $style.itemKey]">PHOTOS</span>
					<span :class="$style.itemTitle">写真</span>
					<span :class="$style.itemText">撮った写真をまとめてシェア。思い出をみんなで楽しめます。</span>
				</li>
				<li :class="$style.listItem">
					<span :class="[$style.mono, $style.num]">D</span>
					<span :class="[$style.mono, $style.itemKey]">VRSNS</span>
					<span :class="$style.itemTitle">VRSNS ユーザー歓迎</span>
					<span :class="$style.itemText">ぶいちゃ以外の VRSNS ユーザーも歓迎です。</span>
				</li>
			</ul>
		</div>
	</section>

	<!-- 03 SERVICES -->
	<section :class="$style.section">
		<div :class="$style.inner">
			<div :class="[$style.mono, $style.label]">03 / BUICHA.JP SERVICES</div>
			<h2 :class="$style.h2">Buicha.jp のサービス</h2>
			<div :class="$style.tiles">
				<a v-for="s in publicServices" :key="s.url" :href="s.url" target="_blank" rel="noopener" :class="$style.tile">
					<span :class="$style.tileHead">
						<span :class="$style.tileIcon"><img :src="s.icon" alt="" :class="$style.tileIconImg"/></span>
						<span :class="$style.tileArrow">↗</span>
					</span>
					<span :class="$style.tileName">{{ s.name }}</span>
					<span :class="[$style.mono, $style.tileProduct]">{{ s.product }}</span>
					<span :class="$style.tileDesc">{{ s.description }}</span>
				</a>
			</div>

			<template v-if="inviteOnlyServices.length > 0">
				<div :class="$style.inviteHead">
					<span :class="[$style.mono, $style.label, $style.labelInline]">INVITE ONLY</span>
					<span :class="[$style.glassBadge, $style.mono]">招待制</span>
				</div>
				<div :class="$style.tiles">
					<a v-for="s in inviteOnlyServices" :key="s.url" :href="s.url" target="_blank" rel="noopener" :class="[$style.tile, $style.tileInvite]">
						<span :class="$style.tileHead">
							<span :class="$style.tileIcon"><img :src="s.icon" alt="" :class="$style.tileIconImg"/></span>
							<span :class="$style.tileArrow">↗</span>
						</span>
						<span :class="$style.tileName">{{ s.name }}<span :class="[$style.outBadge, $style.mono]">招待制</span></span>
						<span :class="[$style.mono, $style.tileProduct]">{{ s.product }}</span>
						<span :class="$style.tileDesc">{{ s.description }}</span>
					</a>
				</div>
			</template>
		</div>
	</section>

	<a :href="portalUrl" target="_blank" rel="noopener" :class="$style.banner">
		<span :class="$style.bannerText">
			<span :class="[$style.mono, $style.bannerLabel]">PORTAL</span>
			<span :class="$style.bannerTitle">apps.buicha.jp</span>
			<span :class="$style.bannerSub">Buicha.jp のすべてのサービスを見る</span>
		</span>
		<span :class="$style.bannerBtn">↗</span>
	</a>

	<!-- 04 NOW -->
	<section :class="$style.section">
		<div :class="$style.inner">
			<div :class="[$style.mono, $style.label]">04 / NOW</div>
			<h2 :class="$style.h2">いまのぶいちゃすきー</h2>
			<div v-if="stats && meta.clientOptions.showActivitiesForVisitor !== false" :class="$style.stats">
				<div :class="$style.stat">
					<div :class="$style.statNum"><MkNumber :value="stats.originalUsersCount"/></div>
					<div :class="[$style.mono, $style.statCap]">{{ i18n.ts.users }} / USERS</div>
				</div>
				<div :class="$style.stat">
					<div :class="$style.statNum"><MkNumber :value="stats.originalNotesCount"/></div>
					<div :class="[$style.mono, $style.statCap]">{{ i18n.ts.notes }} / NOTES</div>
				</div>
			</div>
			<div :class="$style.panels">
				<div v-if="meta.policies.ltlAvailable && meta.clientOptions.showTimelineForVisitor !== false" :class="$style.panel">
					<div :class="[$style.mono, $style.panelHead]">{{ i18n.ts.letsLookAtTimeline }}</div>
					<div :class="$style.tlBody">
						<MkStreamingNotesTimeline src="local"/>
					</div>
				</div>
				<div v-if="meta.clientOptions.showActivitiesForVisitor !== false" :class="$style.panel">
					<XActiveUsersChart/>
				</div>
			</div>
		</div>
	</section>

	<!-- FOOTER -->
	<footer :class="$style.footer">
		<div :class="$style.footerInner">
			<div :class="$style.footerLinks">
				<a v-if="meta.tosUrl" :href="meta.tosUrl" target="_blank" rel="noopener" :class="$style.footerLink">利用規約</a>
				<a v-if="meta.inquiryUrl" :href="meta.inquiryUrl" target="_blank" rel="noopener" :class="$style.footerLink">お問い合わせ</a>
				<MkA to="/about" :class="$style.footerLink">サーバー情報</MkA>
				<a :href="statusUrl" target="_blank" rel="noopener" :class="$style.footerLink">ステータス</a>
				<a href="https://github.com/kazunamine/misskeybuichajp" target="_blank" rel="noopener" :class="$style.footerLink">Source code (AGPL-3.0)</a>
				<a href="https://misskey-hub.net/" target="_blank" rel="noopener" :class="$style.footerLink">Powered by Misskey</a>
			</div>
			<div :class="[$style.mono, $style.footerCopy]">BUICHA.JP / ぶいちゃすきー</div>
		</div>
	</footer>
</div>
</template>

<script lang="ts" setup>
import MkNumber from '@/components/MkNumber.vue';
import MkStreamingNotesTimeline from '@/components/MkStreamingNotesTimeline.vue';
import XActiveUsersChart from '@/components/MkVisitorDashboard.ActiveUsersChart.vue';
import MkInfo from '@/components/MkInfo.vue';
import XSigninDialog from '@/components/MkSigninDialog.vue';
import XSignupDialog from '@/components/MkSignupDialog.vue';
import { ref } from 'vue';
import * as Misskey from 'misskey-js';
import * as os from '@/os.js';
import { misskeyApi } from '@/utility/misskey-api.js';
import { i18n } from '@/i18n.js';
import { instance as meta } from '@/instance.js';
import { publicServices, inviteOnlyServices, statusUrl, portalUrl } from '@/buicha/services.js';

// ---- hero art (decorative, deterministic) ----
const ART_W = 1600;
const ART_H = 900;
const ART_CELL = 50;
const ART_COLS = ART_W / ART_CELL;
const ART_ROWS = ART_H / ART_CELL;

function mulberry32(seed: number) {
	let a = seed;
	return () => {
		a = (a + 0x6D2B79F5) | 0;
		let t = Math.imul(a ^ (a >>> 15), 1 | a);
		t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
		return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
	};
}

// グリッド単位 (列, 行, 幅, 高さ)
const blocks = [
	{ c: 25, r: 0, w: 5, h: 3 },
	{ c: 29, r: 6, w: 3, h: 4 },
	{ c: 19, r: 3, w: 2, h: 2 },
	{ c: 27, r: 11, w: 2, h: 2 },
];

// 密な領域が島状に分かれるよう、島の中心と半径を固定で持つ
const islands = [
	{ c: 26, r: 3, rad: 11 },
	{ c: 14, r: 2, rad: 6 },
	{ c: 30, r: 12, rad: 6 },
	{ c: 21, r: 9, rad: 5 },
	{ c: 6, r: 1, rad: 4 },
];

const glyphKinds = ['dot', 'dot', 'dot', 'dot', 'plus', 'plus', 'x', 'x', 'sq', 'ring', 'ring', 'slash'];

const glyphs = (() => {
	const rand = mulberry32(20260101);
	const out: { key: string; kind: string; x: number; y: number; o: number; blink: boolean }[] = [];
	for (let r = 0; r < ART_ROWS; r++) {
		for (let c = 0; c < ART_COLS; c++) {
			const pR = rand();
			const pK = rand();
			const pO = rand();
			const pB = rand();
			if (blocks.some(b => c >= b.c && c < b.c + b.w && r >= b.r && r < b.r + b.h)) continue;
			let island = 0;
			for (const i of islands) {
				island = Math.max(island, 1 - Math.hypot(c - i.c, r - i.r) / i.rad);
			}
			// 右・上ほど濃く、左下 (見出し領域) と右下 (CTA) は空ける
			const w = 0.2 + (c / ART_COLS) * 0.9 - (r / ART_ROWS) * 1.1;
			const score = Math.min(1, island * 2.4) * Math.min(1, Math.max(0, w) * 3);
			if (pR >= score) continue;
			out.push({
				key: `${c}-${r}`,
				kind: glyphKinds[Math.floor(pK * glyphKinds.length)],
				x: c * ART_CELL + 13,
				y: r * ART_CELL + 13,
				o: Math.round((0.35 + pO * 0.65) * 100) / 100,
				blink: pB < 0.08,
			});
		}
	}
	return out;
})();

const TRACK = '880,80 1320,80 1520,280 1520,460 1320,660 1040,660 840,460 840,280';
const TRACK_INNER = '900,110 1308,110 1490,292 1490,448 1308,630 1052,630 870,448 870,292';
const crosshairs = [{ x: 810, y: 290 }, { x: 1350, y: 250 }, { x: 1180, y: 400 }];
const dots = [{ x: 690, y: 170 }, { x: 930, y: 410 }, { x: 1250, y: 150 }, { x: 1500, y: 400 }];

const stats = ref<Misskey.entities.StatsResponse | null>(null);

if (meta.clientOptions.showActivitiesForVisitor !== false) {
	misskeyApi('stats', {}).then((res) => {
		stats.value = res;
	});
}

function signin() {
	const { dispose } = os.popup(XSigninDialog, {
		autoSet: true,
	}, {
		closed: () => dispose(),
	});
}

function signup() {
	const { dispose } = os.popup(XSignupDialog, {
		autoSet: true,
	}, {
		closed: () => dispose(),
	});
}
</script>

<style lang="scss" module>
.root {
	--bk-lime: #c8f031;
	--bk-ink: #0e0f0c;
	--bk-paper: #edeeea;
	--bk-line: rgba(14, 15, 12, 0.12);
	--bk-white: #fff;
	--bk-mono: ui-monospace, "SF Mono", Menlo, monospace;
	--bk-sans: "Helvetica Neue", "Hiragino Sans", "Noto Sans JP", sans-serif;
	// 罫線グリッド (グラデーション不使用の SVG)
	--bk-grid: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='80' height='80'%3E%3Cpath d='M80 0V80H0' fill='none' stroke='rgba(14,15,12,0.12)' stroke-width='1'/%3E%3C/svg%3E");

	height: 100cqh;
	overflow-x: hidden;
	overflow-y: auto;
	overscroll-behavior: contain;
	box-sizing: border-box;
	background: var(--bk-paper);
	color: var(--bk-ink);
	font-family: var(--bk-sans);
	line-height: 1.7;
}

.root *,
.root *::before,
.root *::after {
	box-sizing: border-box;
}

:where(.root) a {
	color: inherit;
	text-decoration: none;
}

.root :focus-visible {
	outline: 2px solid #0E0F0C;
	outline-offset: 2px;
}

// 暗い地 (ヒーロー / apps バナー / フッター) ではライム
.hero :focus-visible,
.banner:focus-visible,
.footer :focus-visible {
	outline-color: #C8F031;
}

.mono {
	font-family: var(--bk-mono);
	font-size: 11px;
	letter-spacing: 0.08em;
	text-transform: uppercase;
}

// ---- hero ----
.hero {
	position: relative;
	width: 100%;
	height: 100cqh;
	min-height: 560px;
	overflow: clip;
	background: var(--bk-ink);
	color: var(--bk-white);
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	padding: 24px clamp(16px, 4vw, 48px) clamp(24px, 4vw, 48px);
}

.heroArt {
	position: absolute;
	inset: 0;
	width: 100%;
	height: 100%;
	color: var(--bk-lime);
	pointer-events: none; // 装飾レイヤ。ホイール操作を透過させる (issue #17680)
}

.blink {
	animation: bk-blink 5s ease-in-out infinite;
}

@keyframes bk-blink {
	0%, 100% { opacity: var(--o, 1); }
	50% { opacity: calc(var(--o, 1) * 0.25); }
}

.artLime rect {
	fill: var(--bk-lime);
}

.trackEdge {
	fill: none;
	stroke: var(--bk-lime);
	stroke-width: 46;
	stroke-linejoin: miter;
}

.trackBand {
	fill: none;
	stroke: var(--bk-ink);
	stroke-width: 38;
	stroke-linejoin: miter;
}

.trackLine {
	fill: none;
	stroke: var(--bk-lime);
	stroke-width: 1.5;
	opacity: 0.7;
}

.artLine {
	fill: none;
	stroke: var(--bk-paper);
	stroke-width: 1.5;
	opacity: 0.85;
}

.artDots circle {
	fill: var(--bk-ink);
	stroke: var(--bk-lime);
	stroke-width: 2;
}

.artText {
	fill: var(--bk-paper);
	font-family: var(--bk-mono);
	font-size: 15px;
	letter-spacing: 0.1em;
	opacity: 0.75;
}

.glassPanel {
	position: absolute;
	left: 58%;
	top: 24%;
	width: min(30vw, 340px);
	display: flex;
	flex-direction: column;
	gap: 6px;
	padding: 22px 24px 40px;
	border-radius: 28px;
	background: rgba(255, 255, 255, 0.14);
	-webkit-backdrop-filter: blur(14px) saturate(180%);
	backdrop-filter: blur(14px) saturate(180%);
	border: 1px solid rgba(255, 255, 255, 0.35);
	box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.6), 0 1px 2px rgba(0, 0, 0, 0.18), 0 6px 14px -6px rgba(0, 0, 0, 0.3);
	color: var(--bk-white);
	text-transform: none;
	pointer-events: none;
}

.panelNo {
	margin-bottom: 36px;
	color: var(--bk-lime);
	font-size: 22px;
	font-weight: 700;
}

.heroTop,
.heroBottom {
	position: relative;
	display: flex;
	justify-content: space-between;
	gap: 16px;
}

.heroTop {
	align-items: center;
}

.brand {
	display: flex;
	align-items: center;
	gap: 10px;
	min-width: 0;
}

.brandIcon {
	width: 28px;
	height: 28px;
	object-fit: contain;
	border-radius: 6px;
	flex: none;
}

.brandName {
	font-weight: 700;
	font-size: 14px;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.heroTopRight {
	display: flex;
	align-items: center;
	gap: 14px;
	flex: none;
}

.scrollHint {
	opacity: 0.85;
}

.dot {
	display: inline-block;
	width: 6px;
	height: 6px;
	margin-right: 8px;
	border-radius: 50%;
	background: var(--bk-lime);
}

// ---- liquid glass ----
.glassChip,
.glassBadge,
.pillGlass {
	background: rgba(255, 255, 255, 0.14);
	-webkit-backdrop-filter: blur(14px) saturate(180%);
	backdrop-filter: blur(14px) saturate(180%);
	border: 1px solid rgba(255, 255, 255, 0.35);
	box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.6), 0 1px 2px rgba(0, 0, 0, 0.18), 0 6px 14px -6px rgba(0, 0, 0, 0.3);
	color: var(--bk-white);
}

.glassChip {
	display: inline-flex;
	align-items: center;
	padding: 6px 12px;
	border-radius: 999px;
}

.heroBottom {
	align-items: flex-end;
	flex-wrap: wrap;
}

.heroText {
	flex: 1 1 520px;
	min-width: 0;
}

.heroLabel {
	margin-bottom: 14px;
	color: var(--bk-lime);
	overflow-wrap: anywhere;
}

.heroTitle {
	margin: 0;
	font-size: clamp(40px, 11vw, 120px);
	font-weight: 800;
	letter-spacing: -0.03em;
	line-height: 1.05;
	overflow-wrap: anywhere;
}

.heroLead {
	margin: 16px 0 0;
	max-width: 36em;
	font-size: clamp(14px, 1.6vw, 18px);
	font-weight: 500;
}

.heroWarn {
	margin-top: 16px;
	max-width: 480px;
}

.heroCta {
	display: flex;
	gap: 12px;
	flex-wrap: wrap;
}

.pill {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 8px;
	min-width: 148px;
	padding: 14px 28px;
	border-radius: 999px;
	font-family: var(--bk-sans);
	font-size: 15px;
	font-weight: 700;
	cursor: pointer;
	transition: background-color 0.15s ease, color 0.15s ease, border-color 0.15s ease;
}

.pillGlass:hover {
	background: rgba(255, 255, 255, 0.28);
}

.pillLime {
	background: var(--bk-lime);
	color: var(--bk-ink);
	border: 1px solid var(--bk-lime);

	&:hover {
		background: var(--bk-white);
		border-color: var(--bk-white);
	}

	&:hover .arrow {
		transform: translateX(3px);
	}
}

.arrow {
	display: inline-block;
	transition: transform 0.15s ease;
}

// ---- section / grid ----
.section {
	position: relative;
	padding: clamp(56px, 9vw, 120px) clamp(16px, 4vw, 48px);
	background-color: var(--bk-paper);
	background-image: var(--bk-grid);
	background-size: 80px 80px;
	border-bottom: 1px solid var(--bk-line);

	// 角のクロスマーク
	&::before,
	&::after {
		content: '+';
		position: absolute;
		top: 12px;
		font-family: var(--bk-mono);
		font-size: 18px;
		line-height: 1;
		color: var(--bk-ink);
	}

	&::before {
		left: 12px;
	}

	&::after {
		right: 12px;
	}
}

.inner {
	position: relative;
	width: min(1120px, 100%);
	margin: 0 auto;
}

.label {
	margin-bottom: 20px;
	color: var(--bk-ink);
	opacity: 0.7;
}

.labelInline {
	margin-bottom: 0;
}

.h2 {
	margin: 0 0 clamp(28px, 5vw, 56px);
	font-size: clamp(32px, 6vw, 72px);
	font-weight: 800;
	letter-spacing: -0.03em;
	line-height: 1.1;
	overflow-wrap: anywhere;
}

.list {
	margin: 0;
	padding: 0;
	list-style: none;
	border-top: 1px solid var(--bk-ink);
}

.listItem {
	display: grid;
	grid-template-columns: 56px 190px minmax(0, 1fr) minmax(0, 1.6fr);
	gap: 8px 20px;
	align-items: baseline;
	padding: 22px 0;
	border-bottom: 1px solid var(--bk-line);
}

.num {
	color: var(--bk-ink);
	font-weight: 700;
}

.itemKey {
	opacity: 0.6;
}

.itemTitle {
	font-size: clamp(18px, 2vw, 24px);
	font-weight: 700;
	letter-spacing: -0.02em;
}

.itemText {
	font-size: 14px;
	line-height: 1.8;
	opacity: 0.8;
}

.betaLine {
	margin: -24px 0 36px;
	font-size: 15px;
}

.mark {
	display: inline-block;
	margin-right: 8px;
	padding: 2px 10px;
	background: var(--bk-lime);
	color: var(--bk-ink);
	font-weight: 700;
	border-radius: 2px;
}

// ---- services ----
.tiles {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(min(100%, 260px), 1fr));
	gap: 12px;
}

.tile {
	display: flex;
	flex-direction: column;
	gap: 6px;
	min-width: 0;
	padding: 18px;
	background: var(--bk-white);
	border: 1px solid var(--bk-line);
	border-radius: 6px;
	transition: border-color 0.15s ease;

	&:hover {
		border-color: var(--bk-ink);
	}

	&:hover .tileArrow {
		background: var(--bk-lime);
		transform: translate(2px, -2px);
	}
}

.tileInvite {
	border-style: dashed;
	border-color: rgba(14, 15, 12, 0.35);
}

.tileHead {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 10px;
}

.tileIcon {
	display: inline-flex;
	width: 44px;
	height: 44px;
	border-radius: 6px;
	overflow: clip;
	background: var(--bk-paper);
}

.tileIconImg {
	width: 100%;
	height: 100%;
	object-fit: contain;
}

.tileArrow {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	width: 36px;
	height: 36px;
	border-radius: 50%;
	border: 1px solid var(--bk-ink);
	font-size: 16px;
	transition: background-color 0.15s ease, transform 0.15s ease;
}

.tileName {
	font-size: 18px;
	font-weight: 700;
	letter-spacing: -0.02em;
	overflow-wrap: anywhere;
}

.tileProduct {
	opacity: 0.6;
}

.tileDesc {
	font-size: 13px;
	line-height: 1.7;
	opacity: 0.8;
}

.inviteHead {
	display: flex;
	align-items: center;
	gap: 12px;
	margin: 40px 0 16px;
}

// 明るい地の上ではリキッドグラスを暗めに調整
.inviteHead .glassBadge {
	padding: 4px 12px;
	border-radius: 999px;
	background: rgba(14, 15, 12, 0.55);
	border-color: rgba(14, 15, 12, 0.4);
}

.outBadge {
	display: inline-block;
	margin-left: 8px;
	padding: 2px 8px;
	border: 1px solid var(--bk-ink);
	border-radius: 999px;
	vertical-align: middle;
	font-size: 10px;
}

// ---- portal banner ----
.banner {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 24px;
	width: 100%;
	padding: clamp(40px, 7vw, 96px) clamp(16px, 4vw, 48px);
	background: var(--bk-ink);
	color: var(--bk-white);
	transition: background-color 0.2s ease, color 0.2s ease;

	&:hover {
		background: var(--bk-lime);
		color: var(--bk-ink);
	}

	&:hover .bannerBtn {
		background: var(--bk-ink);
		color: var(--bk-lime);
		transform: translate(4px, -4px);
	}
}

.bannerText {
	display: flex;
	flex-direction: column;
	gap: 10px;
	min-width: 0;
}

.bannerLabel {
	opacity: 0.7;
}

.bannerTitle {
	font-size: clamp(32px, 8vw, 88px);
	font-weight: 800;
	letter-spacing: -0.03em;
	line-height: 1.05;
	overflow-wrap: anywhere;
}

.bannerSub {
	font-size: clamp(14px, 1.8vw, 20px);
	font-weight: 500;
}

.bannerBtn {
	flex: none;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	width: clamp(56px, 9vw, 112px);
	height: clamp(56px, 9vw, 112px);
	border-radius: 50%;
	background: var(--bk-lime);
	color: var(--bk-ink);
	font-size: clamp(24px, 4vw, 48px);
	transition: background-color 0.2s ease, color 0.2s ease, transform 0.2s ease;
}

// ---- now ----
.stats {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(min(100%, 240px), 1fr));
	gap: 12px;
	margin-bottom: 32px;
	border-top: 1px solid var(--bk-ink);
	padding-top: 20px;
}

.statNum {
	font-size: clamp(56px, 12vw, 160px);
	font-weight: 800;
	letter-spacing: -0.04em;
	line-height: 1;
	overflow-wrap: anywhere;
}

.statCap {
	margin-top: 10px;
	opacity: 0.7;
}

.panels {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(min(100%, 340px), 1fr));
	gap: 12px;
	align-items: start;
}

.panel {
	min-width: 0;
	overflow: clip;
	background: var(--MI_THEME-panel);
	color: var(--MI_THEME-fg);
	border: 1px solid var(--MI_THEME-divider);
	border-radius: 6px;
}

.panelHead {
	padding: 12px 16px;
	color: var(--MI_THEME-fg);
	border-bottom: 1px solid var(--MI_THEME-divider);
}

.tlBody {
	height: 400px;
	background: var(--MI_THEME-bg);
	overflow: auto;
}

// ---- footer ----
.footer {
	background: var(--bk-ink);
	color: var(--bk-white);
	padding: 40px clamp(16px, 4vw, 48px) 48px;
}

.footerInner {
	width: min(1120px, 100%);
	margin: 0 auto;
}

.footerLinks {
	display: flex;
	flex-wrap: wrap;
	gap: 10px 28px;
}

.footerLink {
	font-size: 14px;
	font-weight: 600;
	transition: color 0.15s ease;

	&:hover {
		color: var(--bk-lime);
	}
}

.footerCopy {
	margin-top: 32px;
	opacity: 0.5;
}

// ---- responsive ----
@media (max-width: 860px) {
	.listItem {
		grid-template-columns: 40px minmax(0, 1fr);

		.itemKey,
		.itemTitle,
		.itemText {
			grid-column: 2;
		}
	}
}

@media (max-width: 520px) {
	.heroBottom {
		flex-direction: column;
		align-items: stretch;
	}

	.heroCta {
		flex-direction: column;
	}

	.pill {
		width: 100%;
	}

	.scrollHint {
		display: none;
	}

	// 模様は上半分の右寄りに寄せ、淡くする (見出し・CTA を優先)
	.heroArt {
		inset: 0 0 auto auto;
		width: 200%;
		height: 55%;
		opacity: 0.5;
	}

	.glassPanel {
		display: none;
	}
}

@media (max-width: 860px) {
	.glassPanel {
		left: 52%;
		width: 40vw;
		padding: 14px 16px 24px;
	}
}

@media (prefers-reduced-motion: reduce) {
	.root *,
	.root *::before,
	.root *::after {
		transition: none !important;
		animation: none !important;
	}
}
</style>
