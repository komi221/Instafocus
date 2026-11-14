import Foundation

// 인스타 웹 화면에 주입되는 필터. 인스타 DOM이 바뀌면 이 부분만 손보면 됩니다.
enum FilterScript {
    static let source = #"""
(function () {
  if (window.__dmFilter) return;
  window.__dmFilter = true;

  var CFG = {
    reelText: '릴스를 보냈습니다.',
    videoText: '동영상을 보냈습니다.',
    myPhotoText: '내가 보낸 사진 (숨김)',
    minImg: 120           // 이 크기 미만(프로필 사진 등)은 건드리지 않음
  };

  // 1) 하단/좌측 탭 중 DM 외 메뉴 숨김
  var st = document.createElement('style');
  st.textContent =
    'a[href="/"], a[href^="/explore"], a[href^="/reels"], a[href^="/stories"] { display:none !important; }';
  document.head.appendChild(st);

  function bubble(text) {
    var d = document.createElement('div');
    d.className = 'dm-filtered';
    d.textContent = text;
    d.style.cssText = 'display:inline-block;padding:10px 14px;border-radius:18px;' +
      'background:#262626;color:#fff;font-size:14px;margin:4px 0;';
    return d;
  }

  function hideWith(el, text) {
    if (el.dataset.dmDone) return;
    el.dataset.dmDone = '1';
    el.style.display = 'none';
    if (el.parentNode) el.parentNode.insertBefore(bubble(text), el);
  }

  function rowOf(el) {
    return el.closest('[role="row"]') || el.closest('[role="listitem"]') ||
           el.closest('main') || document.body;
  }

  function isMine(el) {
    var r = el.getBoundingClientRect();
    var c = rowOf(el).getBoundingClientRect();
    return (r.left + r.width / 2) >= (c.left + c.width / 2);   // 오른쪽 정렬 = 내가 보낸 것
  }

  function run() {
    // 2) 릴스 → 텍스트
    document.querySelectorAll('a[href*="/reel/"], a[href*="/reels/"]').forEach(function (a) {
      if (a.closest('.dm-filtered')) return;
      hideWith(a, CFG.reelText);
    });

    // 3) 영상 → 텍스트
    document.querySelectorAll('video').forEach(function (v) {
      var r = v.getBoundingClientRect();
      if (v.dataset.dmDone || v.offsetParent === null) return;
      try { v.pause(); } catch (e) {}
      hideWith(v, CFG.videoText);
    });

    // 4) 사진: 내가 보낸 것은 숨기고 상대가 보낸 것만 표시
    document.querySelectorAll('img').forEach(function (img) {
      if (img.dataset.dmDone) return;
      var r = img.getBoundingClientRect();
      if (r.width < CFG.minImg || r.height < CFG.minImg) return;
      if (img.closest('.dm-filtered')) return;
      if (isMine(img)) hideWith(img, CFG.myPhotoText);
    });
  }

  var t = null;
  function schedule() { clearTimeout(t); t = setTimeout(run, 150); }
  new MutationObserver(schedule).observe(document.documentElement,
    { childList: true, subtree: true });
  document.addEventListener('load', schedule, true);
  setInterval(run, 1500);
  run();
})();
"""#
}
