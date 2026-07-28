<template>
  <div v-if="currentNotice && !hidden" class="notice-marquee">
    <div class="marquee-wrapper">
      <span class="marquee-label">公告</span>
      <div class="marquee-track">
        <span ref="measurer" class="marquee-measurer" aria-hidden="true">{{ displayText }}</span>
        <span v-if="startPx > 0" class="marquee-text" :key="currentIndex"
              :style="{ '--start': startPx + 'px', '--end': endPx + 'px' }"
              @animationend="nextNotice">
          {{ displayText }}
        </span>
      </div>
    </div>
    <i class="el-icon-close marquee-close" @click.stop="handleClose" />
  </div>
</template>

<script>
import { listNoticeTopMarquee } from "@/api/system/notice";

export default {
  name: "NoticeMarquee",
  data() {
    return {
      hidden: false,
      notices: [],
      currentIndex: 0,
      startPx: 0,
      endPx: 0
    }
  },
  computed: {
    currentNotice() {
      return this.notices.length > 0 ? this.notices[this.currentIndex] : null;
    },
    displayText() {
      if (!this.currentNotice) return "";
      return this.currentNotice.noticeTitle + "：" + this.stripHtml(this.currentNotice.noticeContent);
    }
  },
  mounted() {
    this.fetchMarquee();
  },
  methods: {
    fetchMarquee() {
      listNoticeTopMarquee().then(res => {
        if (res.data && res.data.length > 0) {
          this.notices = res.data;
          this.currentIndex = 0;
          this.$nextTick(() => this.scheduleAnimation());
        }
      });
    },
    nextNotice() {
      this.startPx = 0;
      this.currentIndex = (this.currentIndex + 1) % this.notices.length;
      this.$nextTick(() => this.scheduleAnimation());
    },
    scheduleAnimation() {
      const el = this.$el;
      if (!el) return;
      const track = el.querySelector('.marquee-track');
      const measurer = el.querySelector('.marquee-measurer');
      if (track && measurer) {
        this.startPx = track.offsetWidth;
        this.endPx = -measurer.offsetWidth;
      }
    },
    stripHtml(html) {
      const div = document.createElement("div");
      div.innerHTML = html || "";
      return div.textContent || div.innerText || "";
    },
    handleClose() {
      this.hidden = true;
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
  overflow: hidden;
}
.marquee-wrapper {
  flex: 1;
  display: flex;
  align-items: center;
  overflow: hidden;
}
.marquee-label {
  flex-shrink: 0;
  background: #faad14;
  color: #fff;
  font-size: 12px;
  padding: 0 6px;
  border-radius: 2px;
  margin-right: 8px;
}
.marquee-track {
  flex: 1;
  overflow: hidden;
  position: relative;
  height: 1.5em;
}
.marquee-measurer {
  position: absolute;
  visibility: hidden;
  white-space: nowrap;
  font-size: 13px;
}
.marquee-text {
  position: absolute;
  left: 0;
  top: 0;
  white-space: nowrap;
  font-size: 13px;
  color: #333;
  animation: marquee-scroll 15s linear;
}
@keyframes marquee-scroll {
  from { transform: translateX(var(--start)); }
  to { transform: translateX(var(--end)); }
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