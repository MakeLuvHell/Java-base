<template>
  <div v-if="notice" class="notice-marquee" @click="handleClose">
    <div class="marquee-wrapper">
      <span class="marquee-label">公告</span>
      <span class="marquee-text">{{ notice.noticeTitle }}：{{ stripHtml(notice.noticeContent) }}</span>
    </div>
    <i class="el-icon-close marquee-close" @click.stop="handleClose" />
  </div>
</template>

<script>
import { listNoticeTopMarquee, markNoticeRead } from "@/api/system/notice";

export default {
  name: "NoticeMarquee",
  data() {
    return {
      notice: null
    }
  },
  mounted() {
    this.fetchMarquee();
  },
  methods: {
    fetchMarquee() {
      listNoticeTopMarquee().then(res => {
        if (res.data && res.data.noticeId) {
          this.notice = res.data;
        }
      });
    },
    stripHtml(html) {
      const div = document.createElement("div");
      div.innerHTML = html || "";
      return div.textContent || div.innerText || "";
    },
    handleClose() {
      if (this.notice && this.notice.noticeId) {
        markNoticeRead(this.notice.noticeId).then(() => {
          this.notice = null;
        }).catch(() => {
          this.notice = null;
        });
      }
    }
  }
}
</script>

<style scoped lang="scss">
.notice-marquee {
  display: flex;
  align-items: center;
  height: 36px;
  background: #fffbe6;
  border-bottom: 1px solid #ffe58f;
  padding: 0 16px;
  cursor: pointer;
  overflow: hidden;
}
.marquee-wrapper {
  flex: 1;
  overflow: hidden;
  white-space: nowrap;
}
.marquee-label {
  display: inline-block;
  background: #faad14;
  color: #fff;
  font-size: 12px;
  padding: 0 6px;
  border-radius: 2px;
  margin-right: 8px;
  vertical-align: middle;
}
.marquee-text {
  display: inline-block;
  vertical-align: middle;
  font-size: 13px;
  color: #333;
  animation: marquee-scroll 15s linear infinite;
}
@keyframes marquee-scroll {
  from { transform: translateX(100vw); }
  to { transform: translateX(-100%); }
}
.marquee-close {
  margin-left: 12px;
  color: #999;
  font-size: 14px;
  flex-shrink: 0;
}
.marquee-close:hover {
  color: #333;
}
</style>