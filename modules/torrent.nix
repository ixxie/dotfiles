{
  pkgs,
  ...
}: let
  stigTheme = pkgs.writeText "base16.theme" ''
    # base16-friendly stig theme — transparent backgrounds

    $bg = default
    $bg_f = dark gray

    # chrome
    cli             light gray on $bg
    prompt          yellow,bold on $bg
    find.highlight  black on yellow

    # tabs — unfocused subtle, focused uses standout (reverse video)
    tabs.unfocused                dark gray       on $bg
    tabs.focused                  white,standout  on $bg
    tabs.torrentlist.unfocused    dark cyan       on $bg
    tabs.torrentlist.focused      light cyan,standout on $bg
    tabs.torrentdetails.unfocused dark blue       on $bg
    tabs.torrentdetails.focused   light blue,standout on $bg
    tabs.filelist.unfocused       dark magenta    on $bg
    tabs.filelist.focused         light magenta,standout on $bg
    tabs.peerlist.unfocused       dark green      on $bg
    tabs.peerlist.focused         light green,standout on $bg
    tabs.trackerlist.unfocused    dark gray       on $bg
    tabs.trackerlist.focused      white,standout  on $bg
    tabs.settinglist.unfocused    brown           on $bg
    tabs.settinglist.focused      yellow,standout on $bg
    tabs.help.unfocused           dark green      on $bg
    tabs.help.focused             light green,standout on $bg

    # topbar
    topbar                    light gray    on $bg
    topbar.host.connected     light green   on $bg
    topbar.host.connecting    yellow        on $bg
    topbar.host.disconnected  light red     on $bg
    topbar.help.key           light cyan    on $bg
    topbar.help.equals        light cyan    on $bg
    topbar.help.label         light cyan    on $bg
    topbar.help.space         light cyan    on $bg

    # bottombar
    bottombar                             light gray     on $bg
    bottombar.important                   light red,bold on $bg
    bottombar.marked                      yellow,bold    on $bg
    bottombar.bandwidth.up                light green    on $bg
    bottombar.bandwidth.up.highlighted    light green,bold on $bg
    bottombar.bandwidth.down              light cyan     on $bg
    bottombar.bandwidth.down.highlighted  light cyan,bold on $bg

    # log
    log                        light gray     on $bg
    log.timestamp              dark cyan      on $bg
    log.info                   light green    on $bg
    log.error                  light red,bold on $bg
    log.debug                  yellow         on $bg
    log.dupecount              light cyan     on $bg
    log.scrollbar              light gray     on $bg_f

    # keychains
    keychains              light gray   on $bg
    keychains.header       light gray   on $bg_f
    keychains.keys         light gray   on $bg
    keychains.keys.next    yellow       on $bg
    keychains.action       white        on $bg
    keychains.description  white        on $bg

    # completion
    completion               light gray   on $bg
    completion.category      light gray,bold,underline on $bg
    completion.item          light gray   on $bg
    completion.item.focused  black,bold   on yellow
    completion.scrollbar     light gray   on $bg_f

    # help
    helptext            light gray on $bg
    helptext.scrollbar  light gray on $bg_f

    # torrent list
    torrentlist                                        default              on $bg
    torrentlist.focused                                default              on $bg_f
    torrentlist.header                                 light gray,underline on $bg
    torrentlist.scrollbar                              light gray           on $bg_f

    $id_fg = white
    torrentlist.id.header                              $id_fg,underline on $bg
    torrentlist.id.unfocused                           $id_fg           on $bg
    torrentlist.id.focused                             $id_fg           on $bg_f

    torrentlist.infohash.header                        $id_fg,underline on $bg
    torrentlist.infohash.unfocused                     $id_fg           on $bg
    torrentlist.infohash.focused                       $id_fg           on $bg_f

    $downloaded_fg = dark cyan
    $downloaded_hl = light cyan
    torrentlist.downloaded.header                      $downloaded_fg,underline on $bg
    torrentlist.downloaded.unfocused                   $downloaded_fg           on $bg
    torrentlist.downloaded.focused                     $downloaded_fg           on $bg_f
    torrentlist.downloaded.highlighted.unfocused       $downloaded_hl           on $bg
    torrentlist.downloaded.highlighted.focused         $downloaded_hl           on $bg_f

    $uploaded_fg = dark green
    $uploaded_hl = light green
    torrentlist.uploaded.header                        $uploaded_fg,underline on $bg
    torrentlist.uploaded.unfocused                     $uploaded_fg           on $bg
    torrentlist.uploaded.focused                       $uploaded_fg           on $bg_f
    torrentlist.uploaded.highlighted.unfocused         $uploaded_hl           on $bg
    torrentlist.uploaded.highlighted.focused           $uploaded_hl           on $bg_f

    $available_fg = dark blue
    $available_hl = light blue
    torrentlist.available.header                       $available_fg,underline on $bg
    torrentlist.available.unfocused                    $available_fg           on $bg
    torrentlist.available.focused                      $available_fg           on $bg_f
    torrentlist.available.highlighted.unfocused        $available_hl           on $bg
    torrentlist.available.highlighted.focused          $available_hl           on $bg_f

    $marked_fg = white
    torrentlist.marked.header                          $marked_fg,underline on $bg
    torrentlist.marked.unfocused                       $marked_fg           on $bg
    torrentlist.marked.focused                         $marked_fg           on $bg_f

    $path_fg = light gray
    torrentlist.path.header                            $path_fg,underline on $bg
    torrentlist.path.unfocused                         $path_fg           on $bg
    torrentlist.path.focused                           $path_fg           on $bg_f

    $peers_fg = light gray
    $peers_hl = white
    torrentlist.peers.header                           $peers_fg,underline on $bg
    torrentlist.peers.unfocused                        $peers_fg           on $bg
    torrentlist.peers.focused                          $peers_fg           on $bg_f
    torrentlist.peers.highlighted.unfocused            $peers_hl           on $bg
    torrentlist.peers.highlighted.focused              $peers_hl           on $bg_f

    $seeds_fg = light gray
    $seeds_hl = white
    torrentlist.seeds.header                           $seeds_fg,underline on $bg
    torrentlist.seeds.unfocused                        $seeds_fg           on $bg
    torrentlist.seeds.focused                          $seeds_fg           on $bg_f
    torrentlist.seeds.highlighted.unfocused            $seeds_hl           on $bg
    torrentlist.seeds.highlighted.focused              $seeds_hl           on $bg_f

    $pctdl_fg = dark blue
    $pctdl_hl = light blue
    torrentlist.%downloaded.header                     $pctdl_fg,underline on $bg
    torrentlist.%downloaded.unfocused                  $pctdl_fg           on $bg
    torrentlist.%downloaded.focused                    $pctdl_fg           on $bg_f
    torrentlist.%downloaded.highlighted.unfocused      $pctdl_hl           on $bg
    torrentlist.%downloaded.highlighted.focused        $pctdl_hl           on $bg_f

    $pctav_fg = dark blue
    $pctav_hl = light blue
    torrentlist.%available.header                      $pctav_fg,underline on $bg
    torrentlist.%available.unfocused                   $pctav_fg           on $bg
    torrentlist.%available.focused                     $pctav_fg           on $bg_f
    torrentlist.%available.highlighted.unfocused       $pctav_hl           on $bg
    torrentlist.%available.highlighted.focused         $pctav_hl           on $bg_f

    $ratedn_fg = dark cyan
    $ratedn_hl = light cyan
    torrentlist.rate-down.header                       $ratedn_fg,underline on $bg
    torrentlist.rate-down.unfocused                    $ratedn_fg           on $bg
    torrentlist.rate-down.focused                      $ratedn_fg           on $bg_f
    torrentlist.rate-down.highlighted.unfocused        $ratedn_hl           on $bg
    torrentlist.rate-down.highlighted.focused          $ratedn_hl           on $bg_f

    $rateup_fg = dark green
    $rateup_hl = light green
    torrentlist.rate-up.header                         $rateup_fg,underline on $bg
    torrentlist.rate-up.unfocused                      $rateup_fg           on $bg
    torrentlist.rate-up.focused                        $rateup_fg           on $bg_f
    torrentlist.rate-up.highlighted.unfocused          $rateup_hl           on $bg
    torrentlist.rate-up.highlighted.focused            $rateup_hl           on $bg_f

    $limdn_fg = dark cyan
    $limdn_hl = light cyan
    torrentlist.limit-rate-down.header                 $limdn_fg,underline on $bg
    torrentlist.limit-rate-down.unfocused              $limdn_fg           on $bg
    torrentlist.limit-rate-down.focused                $limdn_fg           on $bg_f
    torrentlist.limit-rate-down.highlighted.unfocused  $limdn_hl           on $bg
    torrentlist.limit-rate-down.highlighted.focused    $limdn_hl           on $bg_f

    $limup_fg = dark green
    $limup_hl = light green
    torrentlist.limit-rate-up.header                   $limup_fg,underline on $bg
    torrentlist.limit-rate-up.unfocused                $limup_fg           on $bg
    torrentlist.limit-rate-up.focused                  $limup_fg           on $bg_f
    torrentlist.limit-rate-up.highlighted.unfocused    $limup_hl           on $bg
    torrentlist.limit-rate-up.highlighted.focused      $limup_hl           on $bg_f

    $ratio_fg = dark blue
    $ratio_hl = light blue
    torrentlist.ratio.header                           $ratio_fg,underline on $bg
    torrentlist.ratio.unfocused                        $ratio_fg           on $bg
    torrentlist.ratio.focused                          $ratio_fg           on $bg_f
    torrentlist.ratio.highlighted.unfocused            $ratio_hl           on $bg
    torrentlist.ratio.highlighted.focused              $ratio_hl           on $bg_f

    $size_fg = dark magenta
    torrentlist.size.header                            $size_fg,underline on $bg
    torrentlist.size.unfocused                         $size_fg           on $bg
    torrentlist.size.focused                           $size_fg           on $bg_f

    $tracker_fg = light gray
    torrentlist.tracker.header                         $tracker_fg,underline on $bg
    torrentlist.tracker.unfocused                      $tracker_fg           on $bg
    torrentlist.tracker.focused                        $tracker_fg           on $bg_f

    $error_fg = light red
    torrentlist.error.header                           $error_fg,underline on $bg
    torrentlist.error.unfocused                        $error_fg           on $bg
    torrentlist.error.focused                          $error_fg           on $bg_f

    $added_fg = brown
    torrentlist.added.header                           $added_fg,underline on $bg
    torrentlist.added.unfocused                        $added_fg           on $bg
    torrentlist.added.focused                          $added_fg           on $bg_f

    $activity_fg = brown
    torrentlist.activity.header                        $activity_fg,underline on $bg
    torrentlist.activity.unfocused                     $activity_fg           on $bg
    torrentlist.activity.focused                       $activity_fg           on $bg_f

    $created_fg = brown
    torrentlist.created.header                         $created_fg,underline on $bg
    torrentlist.created.unfocused                      $created_fg           on $bg
    torrentlist.created.focused                        $created_fg           on $bg_f

    $completed_fg = brown
    $completed_hl = yellow
    torrentlist.completed.header                       $completed_fg,underline on $bg
    torrentlist.completed.unfocused                    $completed_fg           on $bg
    torrentlist.completed.focused                      $completed_fg           on $bg_f
    torrentlist.completed.highlighted.unfocused        $completed_hl           on $bg
    torrentlist.completed.highlighted.focused          $completed_hl           on $bg_f

    $eta_fg = brown
    $eta_hl = yellow
    torrentlist.eta.header                             $eta_fg,underline on $bg
    torrentlist.eta.unfocused                          $eta_fg           on $bg
    torrentlist.eta.focused                            $eta_fg           on $bg_f
    torrentlist.eta.highlighted.unfocused              $eta_hl           on $bg
    torrentlist.eta.highlighted.focused                $eta_hl           on $bg_f

    $started_fg = brown
    torrentlist.started.header                         $started_fg,underline on $bg
    torrentlist.started.unfocused                      $started_fg           on $bg
    torrentlist.started.focused                        $started_fg           on $bg_f

    # torrent status colors
    $st_idle        = light gray
    $st_downloading = light cyan
    $st_uploading   = light green
    $st_connected   = light magenta
    $st_seeding     = light gray
    $st_stopped     = dark blue
    $st_queued      = brown
    $st_isolated    = light red
    $st_verifying   = yellow
    $st_discovering = light blue

    torrentlist.status.header                   $st_idle,underline on $bg

    torrentlist.status.idle.unfocused           $st_idle        on $bg
    torrentlist.status.idle.focused             $st_idle        on $bg_f
    torrentlist.status.uploading.unfocused      $st_uploading   on $bg
    torrentlist.status.uploading.focused        $st_uploading   on $bg_f
    torrentlist.status.downloading.unfocused    $st_downloading on $bg
    torrentlist.status.downloading.focused      $st_downloading on $bg_f
    torrentlist.status.connected.unfocused      $st_connected   on $bg
    torrentlist.status.connected.focused        $st_connected   on $bg_f
    torrentlist.status.seeding.unfocused        $st_seeding     on $bg
    torrentlist.status.seeding.focused          $st_seeding     on $bg_f
    torrentlist.status.stopped.unfocused        $st_stopped     on $bg
    torrentlist.status.stopped.focused          $st_stopped     on $bg_f
    torrentlist.status.isolated.unfocused       $st_isolated    on $bg
    torrentlist.status.isolated.focused         $st_isolated    on $bg_f
    torrentlist.status.queued.unfocused         $st_queued      on $bg
    torrentlist.status.queued.focused           $st_queued      on $bg_f
    torrentlist.status.verifying.unfocused      $st_verifying   on $bg
    torrentlist.status.verifying.focused        $st_verifying   on $bg_f
    torrentlist.status.discovering.unfocused    $st_discovering on $bg
    torrentlist.status.discovering.focused      $st_discovering on $bg_f

    # torrent name (progress1=completed portion, progress2=remaining)
    torrentlist.name.header                            $st_idle,underline on $bg
    torrentlist.name.idle.progress1.unfocused          light gray,underline on $bg
    torrentlist.name.idle.progress1.focused            light gray,underline on $bg_f
    torrentlist.name.idle.progress2.unfocused          light gray           on $bg
    torrentlist.name.idle.progress2.focused            light gray           on $bg_f
    torrentlist.name.idle.complete.unfocused           light gray           on $bg
    torrentlist.name.idle.complete.focused             light gray           on $bg_f
    torrentlist.name.seeding.progress1.unfocused       $st_seeding,underline on $bg
    torrentlist.name.seeding.progress1.focused         $st_seeding,underline on $bg_f
    torrentlist.name.seeding.progress2.unfocused       $st_seeding           on $bg
    torrentlist.name.seeding.progress2.focused         $st_seeding           on $bg_f
    torrentlist.name.seeding.complete.unfocused        $st_seeding           on $bg
    torrentlist.name.seeding.complete.focused          $st_seeding           on $bg_f
    torrentlist.name.uploading.progress1.unfocused     $st_uploading,underline on $bg
    torrentlist.name.uploading.progress1.focused       $st_uploading,underline on $bg_f
    torrentlist.name.uploading.progress2.unfocused     $st_uploading           on $bg
    torrentlist.name.uploading.progress2.focused       $st_uploading           on $bg_f
    torrentlist.name.uploading.complete.unfocused      $st_uploading           on $bg
    torrentlist.name.uploading.complete.focused        $st_uploading           on $bg_f
    torrentlist.name.downloading.progress1.unfocused   $st_downloading,underline on $bg
    torrentlist.name.downloading.progress1.focused     $st_downloading,underline on $bg_f
    torrentlist.name.downloading.progress2.unfocused   $st_downloading           on $bg
    torrentlist.name.downloading.progress2.focused     $st_downloading           on $bg_f
    torrentlist.name.downloading.complete.unfocused    $st_downloading           on $bg
    torrentlist.name.downloading.complete.focused      $st_downloading           on $bg_f
    torrentlist.name.isolated.progress1.unfocused      $st_isolated,underline on $bg
    torrentlist.name.isolated.progress1.focused        $st_isolated,underline on $bg_f
    torrentlist.name.isolated.progress2.unfocused      $st_isolated           on $bg
    torrentlist.name.isolated.progress2.focused        $st_isolated           on $bg_f
    torrentlist.name.isolated.complete.unfocused       $st_isolated           on $bg
    torrentlist.name.isolated.complete.focused         $st_isolated           on $bg_f
    torrentlist.name.connected.progress1.unfocused     $st_connected,underline on $bg
    torrentlist.name.connected.progress1.focused       $st_connected,underline on $bg_f
    torrentlist.name.connected.progress2.unfocused     $st_connected           on $bg
    torrentlist.name.connected.progress2.focused       $st_connected           on $bg_f
    torrentlist.name.connected.complete.unfocused      $st_connected           on $bg
    torrentlist.name.connected.complete.focused        $st_connected           on $bg_f
    torrentlist.name.queued.progress1.unfocused        $st_queued,underline on $bg
    torrentlist.name.queued.progress1.focused          $st_queued,underline on $bg_f
    torrentlist.name.queued.progress2.unfocused        $st_queued           on $bg
    torrentlist.name.queued.progress2.focused          $st_queued           on $bg_f
    torrentlist.name.queued.complete.unfocused         $st_queued           on $bg
    torrentlist.name.queued.complete.focused           $st_queued           on $bg_f
    torrentlist.name.stopped.progress1.unfocused       $st_stopped,underline on $bg
    torrentlist.name.stopped.progress1.focused         $st_stopped,underline on $bg_f
    torrentlist.name.stopped.progress2.unfocused       $st_stopped           on $bg
    torrentlist.name.stopped.progress2.focused         $st_stopped           on $bg_f
    torrentlist.name.stopped.complete.unfocused        $st_stopped           on $bg
    torrentlist.name.stopped.complete.focused          $st_stopped           on $bg_f
    torrentlist.name.verifying.progress1.unfocused     $st_verifying,underline on $bg
    torrentlist.name.verifying.progress1.focused       $st_verifying,underline on $bg_f
    torrentlist.name.verifying.progress2.unfocused     $st_verifying           on $bg
    torrentlist.name.verifying.progress2.focused       $st_verifying           on $bg_f
    torrentlist.name.verifying.complete.unfocused      $st_verifying           on $bg
    torrentlist.name.verifying.complete.focused        $st_verifying           on $bg_f
    torrentlist.name.discovering.progress1.unfocused   $st_discovering,underline on $bg
    torrentlist.name.discovering.progress1.focused     $st_discovering,underline on $bg_f
    torrentlist.name.discovering.progress2.unfocused   $st_discovering           on $bg
    torrentlist.name.discovering.progress2.focused     $st_discovering           on $bg_f
    torrentlist.name.discovering.complete.unfocused    $st_discovering           on $bg
    torrentlist.name.discovering.complete.focused      $st_discovering           on $bg_f

    # torrent details
    torrentdetails            light gray on $bg
    torrentdetails.error      light red  on $bg
    torrentdetails.scrollbar  light gray on $bg_f

    # file list
    filelist                                   default              on $bg
    filelist.focused                           default              on $bg_f
    filelist.header                            light gray,underline on $bg
    filelist.scrollbar                         light gray           on $bg_f
    filelist.marked.header                     white,underline      on $bg
    filelist.marked.unfocused                  white                on $bg
    filelist.marked.focused                    white                on $bg_f
    filelist.name.header                       light gray,underline on $bg
    filelist.name.file.unfocused               light gray           on $bg
    filelist.name.file.focused                 light gray           on $bg_f
    filelist.name.folder.unfocused             white                on $bg
    filelist.name.folder.focused               white                on $bg_f
    filelist.size.header                       dark magenta,underline on $bg
    filelist.size.unfocused                    dark magenta           on $bg
    filelist.size.focused                      dark magenta           on $bg_f
    filelist.downloaded.header                 dark cyan,underline    on $bg
    filelist.downloaded.unfocused              dark cyan              on $bg
    filelist.downloaded.focused                dark cyan              on $bg_f
    filelist.downloaded.highlighted.unfocused  light cyan             on $bg
    filelist.downloaded.highlighted.focused    light cyan             on $bg_f
    filelist.%downloaded.header                dark blue,underline    on $bg
    filelist.%downloaded.unfocused             dark blue              on $bg
    filelist.%downloaded.focused               dark blue              on $bg_f
    filelist.%downloaded.highlighted.unfocused light blue             on $bg
    filelist.%downloaded.highlighted.focused   light blue             on $bg_f
    filelist.priority.header                   brown,underline        on $bg
    filelist.priority.unfocused                brown                  on $bg
    filelist.priority.focused                  brown                  on $bg_f
    filelist.priority.low.unfocused            brown                  on $bg
    filelist.priority.low.focused              brown                  on $bg_f
    filelist.priority.high.unfocused           yellow                 on $bg
    filelist.priority.high.focused             yellow                 on $bg_f
    filelist.priority.off.unfocused            dark blue              on $bg
    filelist.priority.off.focused              dark blue              on $bg_f

    # peer list
    peerlist                                   default              on $bg
    peerlist.focused                           default              on $bg_f
    peerlist.header                            light gray,underline on $bg
    peerlist.scrollbar                         light gray           on $bg_f
    peerlist.torrent.header                    light gray,underline on $bg
    peerlist.torrent.unfocused                 light gray           on $bg
    peerlist.host.header                       light gray,underline on $bg
    peerlist.host.unfocused                    light gray           on $bg
    peerlist.port.header                       light gray,underline on $bg
    peerlist.port.unfocused                    light gray           on $bg
    peerlist.client.header                     dark magenta,underline on $bg
    peerlist.client.unfocused                  dark magenta           on $bg
    peerlist.%downloaded.header                dark blue,underline    on $bg
    peerlist.%downloaded.unfocused             dark blue              on $bg
    peerlist.%downloaded.highlighted.unfocused light blue             on $bg
    peerlist.rate-down.header                  dark cyan,underline    on $bg
    peerlist.rate-down.unfocused               dark cyan              on $bg
    peerlist.rate-down.highlighted.unfocused   light cyan             on $bg
    peerlist.rate-up.header                    dark green,underline   on $bg
    peerlist.rate-up.unfocused                 dark green             on $bg
    peerlist.rate-up.highlighted.unfocused     light green            on $bg
    peerlist.rate-est.header                   dark green,underline   on $bg
    peerlist.rate-est.unfocused                dark green             on $bg
    peerlist.rate-est.highlighted.unfocused    light green            on $bg
    peerlist.eta.header                        brown,underline        on $bg
    peerlist.eta.unfocused                     brown                  on $bg
    peerlist.eta.highlighted.unfocused         yellow                 on $bg

    # tracker list
    trackerlist                                default              on $bg
    trackerlist.focused                        default              on $bg_f
    trackerlist.header                         light gray,underline on $bg
    trackerlist.scrollbar                      light gray           on $bg_f
    trackerlist.torrent.header                 light gray,underline on $bg
    trackerlist.torrent.unfocused              light gray           on $bg
    trackerlist.torrent.focused                light gray           on $bg_f
    trackerlist.tier.header                    brown,underline      on $bg
    trackerlist.tier.unfocused                 brown                on $bg
    trackerlist.tier.focused                   brown                on $bg_f
    trackerlist.domain.header                  dark magenta,underline on $bg
    trackerlist.domain.unfocused               dark magenta           on $bg
    trackerlist.domain.focused                 dark magenta           on $bg_f
    trackerlist.url-announce.header            light blue,underline   on $bg
    trackerlist.url-announce.unfocused         light blue             on $bg
    trackerlist.url-announce.focused           light blue             on $bg_f
    trackerlist.url-scrape.header              light blue,underline   on $bg
    trackerlist.url-scrape.unfocused           light blue             on $bg
    trackerlist.url-scrape.focused             light blue             on $bg_f
    trackerlist.status.header                  dark cyan,underline    on $bg
    trackerlist.status.unfocused               dark cyan              on $bg
    trackerlist.status.focused                 dark cyan              on $bg_f
    trackerlist.error.header                   light red,underline    on $bg
    trackerlist.error.unfocused                light red              on $bg
    trackerlist.error.focused                  light red              on $bg_f
    trackerlist.error-announce.header          light red,underline    on $bg
    trackerlist.error-announce.unfocused       light red              on $bg
    trackerlist.error-announce.focused         light red              on $bg_f
    trackerlist.error-scrape.header            light red,underline    on $bg
    trackerlist.error-scrape.unfocused         light red              on $bg
    trackerlist.error-scrape.focused           light red              on $bg_f
    trackerlist.downloads.header               light gray,underline   on $bg
    trackerlist.downloads.unfocused            light gray             on $bg
    trackerlist.downloads.focused              light gray             on $bg_f
    trackerlist.leeches.header                 light gray,underline   on $bg
    trackerlist.leeches.unfocused              light gray             on $bg
    trackerlist.leeches.focused                light gray             on $bg_f
    trackerlist.seeds.header                   light gray,underline   on $bg
    trackerlist.seeds.unfocused                light gray             on $bg
    trackerlist.seeds.focused                  light gray             on $bg_f
    trackerlist.last-announce.header           white,underline        on $bg
    trackerlist.last-announce.unfocused        white                  on $bg
    trackerlist.last-announce.focused          white                  on $bg_f
    trackerlist.next-announce.header           white,underline        on $bg
    trackerlist.next-announce.unfocused        white                  on $bg
    trackerlist.next-announce.focused          white                  on $bg_f
    trackerlist.last-scrape.header             white,underline        on $bg
    trackerlist.last-scrape.unfocused          white                  on $bg
    trackerlist.last-scrape.focused            white                  on $bg_f
    trackerlist.next-scrape.header             white,underline        on $bg
    trackerlist.next-scrape.unfocused          white                  on $bg
    trackerlist.next-scrape.focused            white                  on $bg_f

    # setting list
    settinglist                                default              on $bg
    settinglist.focused                        default              on $bg_f
    settinglist.header                         light gray,underline on $bg
    settinglist.scrollbar                      light gray           on $bg_f
    settinglist.name.header                    light blue,underline on $bg
    settinglist.name.unfocused                 light blue           on $bg
    settinglist.name.focused                   light blue           on $bg_f
    settinglist.value.header                   light gray,underline on $bg
    settinglist.value.unfocused                light gray           on $bg
    settinglist.value.focused                  light gray           on $bg_f
    settinglist.value.highlighted.unfocused    white,bold           on $bg
    settinglist.value.highlighted.focused      white,bold           on $bg_f
    settinglist.default.header                 light gray,underline on $bg
    settinglist.default.unfocused              light gray           on $bg
    settinglist.default.focused                light gray           on $bg_f
    settinglist.description.header             light gray,underline on $bg
    settinglist.description.unfocused          light gray           on $bg
    settinglist.description.focused            light gray           on $bg_f
  '';
  stigRc = pkgs.writeText "stig-rc" ''
    set tui.theme ${stigTheme}
  '';
in {
  # torrent daemon
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    user = "ixxie";
    group = "users";
    settings = {
      download-dir = "/home/ixxie/temp";
      incomplete-dir = "/home/ixxie/temp/.incomplete";
      incomplete-dir-enabled = true;
      port-forwarding-enabled = true;
      peer-port = 49164;
      encryption = 1;
      dht-enabled = true;
      pex-enabled = true;
      utp-enabled = true;
      rpc-bind-address = "127.0.0.1";
      rpc-whitelist-enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    stig
  ];

  home-manager.users.ixxie = {
    xdg.configFile."stig/rc".source = stigRc;
  };
}
