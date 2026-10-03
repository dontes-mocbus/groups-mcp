/+  *test, g=groups-mcp
|%
++  same
  |=  [a=* b=*]
  ^-  tang
  (expect-eq !>(a) !>(b))
++  test-clamp-write-group-read-channel
  (same (effective:g %write %read) `%read)
++  test-clamp-read-group-cannot-write
  (same (effective:g %read %write) `%read)
++  test-inherit-write
  (same (effective:g %write %inherit) `%write)
++  test-hidden-group
  (same (effective:g %hide %write) ~)
++  test-hidden-channel
  (same (effective:g %write %hide) ~)
++  test-read-grant-cannot-write
  (expect !>(!(allows:g %write `%read)))
++  test-write-grant-can-read
  (expect !>(`?`(allows:g %read `%write)))
++  test-rows-omit-unconfigured
  =/  jon
    %-  need
    %-  de:json:html
    '''
    {"~zod/personal":{"meta":{"title":"Personal"},"channels":{"chat/~zod/general":{"meta":{"title":"General"}}}},"~zod/secret":{"meta":{"title":"Secret"},"channels":{"chat/~zod/hid":{"meta":{"title":"Hid"}}}}}
    '''
  =/  pol
    %-  malt
    :~  :-  '~zod/personal'
        [%write (malt ~[[%'chat/~zod/general' %read]])]
    ==
  =/  got  (rows:g jon pol)
  =/  exp
    ^-  (list channel-row:g)
    ~[[%'chat/~zod/general' '~zod/personal' 'General' 'chat' %read]]
  (expect-eq !>(got) !>(exp))
++  test-text-of-chat-essay
  =/  jon
    %-  need
    %-  de:json:html
    '''
    {"content":[{"inline":["Hello, World "]}]}
    '''
  (expect-eq !>(`(text-of:g jon)) !>(`'Hello, World '))
++  test-open-group
  =/  flag=@t  '~zod/fresh'
  =/  pol  (open-group:g ~ flag)
  =/  got  (~(got by pol) flag)
  (expect-eq !>(`*`got) !>(`*`[%write ~]))
++  test-open-channel-hidden
  =/  flag=@t  '~zod/personal'
  =/  old=@t  'chat/~zod/old'
  =/  neu=@t  'chat/~zod/neu'
  =/  opened  (open-channel:g ~ flag neu ~[old])
  =/  got  (~(got by pol.opened) flag)
  =/  exp=group-policy:g  [%write (malt ~[[old %hide]])]
  ;:  weld
    (expect-eq !>(`*`got) !>(`*`exp))
    (expect-eq !>(`*`access.opened) !>(`*`%write))
    (same (effective:g ceiling.got %inherit) `%write)
  ==
++  test-open-channel-read-keeps-sibling
  =/  flag=@t  '~zod/personal'
  =/  sib=@t  'chat/~zod/sib'
  =/  neu=@t  'chat/~zod/neu'
  =/  prev
    %-  malt
    :~  :-  flag
        :-  %read
        %-  malt
        ^-  (list [@t over:g])
        ~[[sib %hide] [neu %write]]
    ==
  =/  opened  (open-channel:g prev flag neu ~[sib neu])
  =/  got  (~(got by pol.opened) flag)
  =/  exp=group-policy:g  [%read (malt ~[[sib %hide]])]
  ;:  weld
    (expect-eq !>(`*`got) !>(`*`exp))
    (expect-eq !>(`*`access.opened) !>(`*`%read))
  ==
++  test-open-channel-write-keeps-hidden-sibling
  =/  flag=@t  '~zod/personal'
  =/  sib=@t  'chat/~zod/sib'
  =/  neu=@t  'chat/~zod/neu'
  =/  prev
    %-  malt
    :~  :-  flag
        [%write (malt ~[[sib %hide]])]
    ==
  =/  opened  (open-channel:g prev flag neu ~[sib])
  =/  got  (~(got by pol.opened) flag)
  =/  exp=group-policy:g  [%write (malt ~[[sib %hide]])]
  =/  sib-access  (effective:g ceiling.got (fall (~(get by channels.got) sib) %inherit))
  ;:  weld
    (expect-eq !>(`*`got) !>(`*`exp))
    (expect-eq !>(`*`access.opened) !>(`*`%write))
    (expect-eq !>(`*`sib-access) !>(`*`~))
  ==
++  test-admin-sects
  =/  jon
    %-  need
    %-  de:json:html
    '''
    {"fleet":{"~zod":{"sects":["admin"]}},"bloc":["admin"]}
    '''
  ;:  weld
    (expect !>(=(%.y (is-admin:g jon '~zod'))))
    (expect !>(=(%.n (is-admin:g jon '~nec'))))
  ==
++  test-admin-sects-miss
  =/  jon
    %-  need
    %-  de:json:html
    '''
    {"fleet":{"~zod":{"sects":["member"]}},"bloc":["admin"]}
    '''
  (expect !>(=(%.n (is-admin:g jon '~zod'))))
++  test-parse-term
  ;:  weld
    (same (parse-term:g 'project-notes') `%project-notes)
    (same (parse-term:g 'Bad') ~)
    (same (parse-term:g '9no') ~)
  ==
++  test-group-command-noun
  =/  got
    (group-command:g %project-notes 'Project Notes' 'notes' %secret)
  =/  exp
    [%create %project-notes ['Project Notes' 'notes' '' ''] %secret [~ ~] ~]
  (expect-eq !>(`*`got) !>(`*`exp))
++  test-channel-action-noun
  =/  writers  (silt ~[%admin])
  =/  got
    (channel-action:g %general ~zod %personal 'General' '' writers)
  =/  exp
    [%create %chat %general [~zod %personal] 'General' '' ~ ~ writers]
  (expect-eq !>(`*`got) !>(`*`exp))
++  sample-groups
  ^-  json
  %-  need
  %-  de:json:html
  '''
  {"~zod/personal":{"meta":{"title":"Personal"},"channels":{"chat/~zod/general":{"meta":{"title":"General"}},"chat/~zod/other":{"meta":{"title":"Other"}},"diary/~zod/note":{"meta":{"title":"Note"}},"heap/~zod/pics":{"meta":{"title":"Pics"}}}},"~zod/secret":{"meta":{"title":"Secret"},"channels":{"chat/~zod/hid":{"meta":{"title":"Hid"}}}},"~zod/fresh":{"meta":{"title":"Fresh"},"channels":{"chat/~zod/new":{"meta":{"title":"New"}}}}}
  '''
++  overs
  |=  rows=(list [@t over:g])
  ^-  (map @t over:g)
  (malt rows)
++  pols
  |=  rows=(list [@t group-policy:g])
  ^-  (map @t group-policy:g)
  (malt rows)
++  test-edits-ceiling-keeps-other
  =/  prev
    %-  pols
    :~  :-  '~zod/personal'
        [%write (overs ~[[%'chat/~zod/general' %read]])]
        :-  '~zod/secret'
        [%read (overs ~[[%'chat/~zod/hid' %hide]])]
    ==
  =/  edits=(list manage-edit:g)  ~[[%ceil '~zod/personal' %read]]
  =/  got  (apply-edits:g edits sample-groups prev)
  =/  exp
    %-  pols
    :~  :-  '~zod/personal'
        [%read (overs ~[[%'chat/~zod/general' %read]])]
        :-  '~zod/secret'
        [%read (overs ~[[%'chat/~zod/hid' %hide]])]
    ==
  (expect-eq !>(`*`got) !>(`*`exp))
++  test-edits-inherit-drops-key
  =/  prev
    %-  pols
    :~  :-  '~zod/personal'
        [%write (overs ~[[%'chat/~zod/general' %read] [%'chat/~zod/other' %hide]])]
    ==
  =/  edits=(list manage-edit:g)
    :~  [%over '~zod/personal' 'chat/~zod/general' %inherit]
        [%ceil '~zod/nope' %write]
        [%ceil '~zod/fresh' %hide]
        [%over '~zod/fresh' 'chat/~zod/new' %inherit]
    ==
  =/  got  (apply-edits:g edits sample-groups prev)
  =/  exp
    %-  pols
    :~  :-  '~zod/personal'
        [%write (overs ~[[%'chat/~zod/other' %hide]])]
    ==
  (expect-eq !>(`*`got) !>(`*`exp))
++  test-edits-hide-replaces-write
  =/  prev  (pols ~[[%'~zod/personal' [%write ~]]])
  =/  edits=(list manage-edit:g)  ~[[%ceil '~zod/personal' %hide]]
  =/  got  (apply-edits:g edits sample-groups prev)
  =/  exp  (pols ~[[%'~zod/personal' [%hide ~]]])
  (expect-eq !>(`*`got) !>(`*`exp))
++  test-edits-hide-keeps-override
  =/  edits=(list manage-edit:g)
    :~  [%ceil '~zod/personal' %hide]
        [%over '~zod/personal' 'chat/~zod/general' %read]
    ==
  =/  got  (apply-edits:g edits sample-groups ~)
  =/  exp
    %-  pols
    :~  :-  '~zod/personal'
        [%hide (overs ~[[%'chat/~zod/general' %read]])]
    ==
  (expect-eq !>(`*`got) !>(`*`exp))
++  test-edits-chat-only
  =/  edits=(list manage-edit:g)
    :~  [%ceil '~zod/personal' %write]
        [%over '~zod/personal' 'chat/~zod/general' %read]
        [%over '~zod/personal' 'diary/~zod/note' %write]
        [%over '~zod/personal' 'heap/~zod/pics' %write]
    ==
  =/  got  (apply-edits:g edits sample-groups ~)
  =/  exp
    %-  pols
    :~  :-  '~zod/personal'
        [%write (overs ~[[%'chat/~zod/general' %read]])]
    ==
  (expect-eq !>(`*`got) !>(`*`exp))
++  test-edits-unknown-flag
  =/  prev  (pols ~[[%'~zod/personal' [%write ~]]])
  =/  edits=(list manage-edit:g)  ~[[%ceil '~zod/nope' %read]]
  =/  got  (apply-edits:g edits sample-groups prev)
  (expect-eq !>(`*`got) !>(`*`prev))
++  test-edits-same-map
  =/  prev
    %-  pols
    :~  :-  '~zod/personal'
        [%write (overs ~[[%'chat/~zod/general' %read] [%'chat/~zod/other' %hide]])]
    ==
  =/  edits=(list manage-edit:g)
    :~  [%ceil '~zod/personal' %write]
        [%over '~zod/personal' 'chat/~zod/general' %read]
        [%over '~zod/personal' 'chat/~zod/other' %hide]
        [%ceil '~zod/secret' %hide]
        [%over '~zod/secret' 'chat/~zod/hid' %inherit]
        [%ceil '~zod/fresh' %hide]
        [%over '~zod/fresh' 'chat/~zod/new' %inherit]
    ==
  =/  got  (apply-edits:g edits sample-groups prev)
  (expect-eq !>(`*`got) !>(`*`prev))
++  all-failures
  ;:  weld
    (category "clamp-write" test-clamp-write-group-read-channel)
    (category "clamp-read" test-clamp-read-group-cannot-write)
    (category "inherit" test-inherit-write)
    (category "hidden-group" test-hidden-group)
    (category "hidden-channel" test-hidden-channel)
    (category "read-grant" test-read-grant-cannot-write)
    (category "write-grant" test-write-grant-can-read)
    (category "rows" test-rows-omit-unconfigured)
    (category "text" test-text-of-chat-essay)
    (category "open-group" test-open-group)
    (category "open-hidden" test-open-channel-hidden)
    (category "open-read" test-open-channel-read-keeps-sibling)
    (category "open-write" test-open-channel-write-keeps-hidden-sibling)
    (category "admin" test-admin-sects)
    (category "admin-miss" test-admin-sects-miss)
    (category "term" test-parse-term)
    (category "group-noun" test-group-command-noun)
    (category "channel-noun" test-channel-action-noun)
    (category "edits-ceiling" test-edits-ceiling-keeps-other)
    (category "edits-inherit" test-edits-inherit-drops-key)
    (category "edits-hide" test-edits-hide-replaces-write)
    (category "edits-hide-over" test-edits-hide-keeps-override)
    (category "edits-chat" test-edits-chat-only)
    (category "edits-unknown" test-edits-unknown-flag)
    (category "edits-same" test-edits-same-map)
  ==
--
