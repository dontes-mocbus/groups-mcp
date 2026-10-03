::  Channel policy for %groups-mcp.
::
::    A client scope and this policy both have to allow an action.
::    The ship's own membership is enforced by %channels, not here.
::    Creating a group or channel records the policy that lets clients
::    use it. The manage page can hide it again.
::
/-  wicket
|%
+$  ceil   ?(%hide %read %write)
+$  over   ?(%inherit %hide %read %write)
+$  grant  ?(%read %write)
+$  group-policy
  $:  ceiling=ceil
      channels=(map @t over)
  ==
+$  channel-row
  $:  nest=@t
      group=@t
      title=@t
      kind=@t
      access=grant
  ==
+$  manage-edit
  $%  [%ceil flag=@t cap=ceil]
      [%over flag=@t nest=@t mode=over]
  ==
::
++  scope-list    %'groups-mcp.channels.list'
++  scope-read    %'groups-mcp.channels.read'
++  scope-write   %'groups-mcp.channels.write'
++  scope-create  %'groups-mcp.create'
++  all
  ^-  (list scope:wicket)
  ~[scope-list scope-read scope-write scope-create]
++  copy
  ^-  scope-copy:wicket
  :-  'Groups MCP'
  %-  malt
  ^-  (list [scope:wicket scope-note:wicket])
  :~  :-  scope-list
      ['List channels this ship has exposed to MCP clients.' %off]
      :-  scope-read
      ['Read posts in channels the ship owner has opened for reading.' %off]
      :-  scope-write
      ['Post, reply, and react where the ship owner has opened writing. Starts unchecked.' %ask]
      :-  scope-create
      ['Create groups and chat channels on this ship, and open them to MCP clients. Starts unchecked.' %ask]
  ==
::
::  Missing policy is hidden. The bunt of ?(%hide %read %write) is
::  %write, so *group-policy must not be used as that default.
::
++  hidden-policy
  ^-  group-policy
  [%hide ~]
::
++  rank
  |=  a=?(%hide %read %write %inherit)
  ^-  @ud
  ?-  a
    %inherit  3
    %hide     0
    %read     1
    %write    2
  ==
::
::  +effective: channel override clamped to the group ceiling.
::  Hidden, or a group with no policy, is ~.
::
++  effective
  |=  [ceiling=ceil override=over]
  ^-  (unit grant)
  =/  cap=@ud  (rank ceiling)
  =/  ask=@ud
    ?:  =(override %inherit)  cap
    (rank override)
  =/  got  (min cap ask)
  ?:  =(got 0)  ~
  ?:  =(got 1)  `%read
  `%write
::
++  allows
  |=  [need=grant have=(unit grant)]
  ^-  ?
  ?~  have  %.n
  ?:  =(u.have %write)  %.y
  =(need %read)
::
++  so
  |=  jon=json
  ^-  (unit @t)
  ?.  ?=([%s *] jon)  ~
  `p.jon
::
++  ogot
  |=  [jon=json key=@t]
  ^-  (unit json)
  ?.  ?=([%o *] jon)  ~
  (~(get by p.jon) key)
::
++  kind-of
  |=  nest=@t
  ^-  @t
  =/  t  (trip nest)
  =/  cut  (find "/" t)
  ?~  cut  nest
  (crip (scag u.cut t))
::
::  +rows: channels from the %groups /groups/json scry.
::  The live desk still serves the fleet/cabals shape. Each channel
::  object carries meta.title. The nest cord is "kind/~ship/name".
::
++  as-cord
  |=  jon=(unit json)
  ^-  (unit @t)
  ?+  jon  ~
    [~ [%s *]]  `p.u.jon
  ==
::
++  str-at
  |=  [jon=json key=@t]
  ^-  (unit @t)
  =/  got  (ogot jon key)
  ?+  got  ~
    [~ [%s *]]  `p.u.got
  ==
::
++  title-of
  |=  [c=json nest=@t]
  ^-  @t
  =/  meta  (fall (ogot c 'meta') [%o ~])
  =/  got  (ogot meta 'title')
  ?+  got  nest
    [~ [%s *]]  p.u.got
  ==
::
++  one-row
  |=  [group=@t nest=@t c=json ceiling=ceil override=over]
  ^-  (unit channel-row)
  =/  access  (effective ceiling override)
  =/  title  (title-of c nest)
  =/  kind  (kind-of nest)
  ?-  access
    ~           ~
    [~ %read]   `[nest group title kind %read]
    [~ %write]  `[nest group title kind %write]
  ==
::
++  rows
  |=  [jon=json policy=(map @t group-policy)]
  ^-  (list channel-row)
  ?.  ?=([%o *] jon)  ~
  %-  zing
  %+  turn  ~(tap by p.jon)
  |=  [group=@t g=json]
  ^-  (list channel-row)
  =/  pol  (fall (~(get by policy) group) hidden-policy)
  =/  ch  (ogot g 'channels')
  ?~  ch  ~
  ?.  ?=([%o *] u.ch)  ~
  %+  murn  ~(tap by p.u.ch)
  |=  [nest=@t c=json]
  (one-row group nest c ceiling.pol (fall (~(get by channels.pol) nest) %inherit))
::
++  text-of
  |=  jon=json
  ^-  @t
  (crip (texts jon))
::
++  texts
  |=  jon=json
  ^-  tape
  ?+    jon  ""
      [%s *]
    (trip p.jon)
  ::
      [%a *]
    (zing (turn p.jon texts))
  ::
      [%o *]
    %-  zing
    %+  turn  ~(tap by p.jon)
    |=  [k=@t v=json]
    ?:  ?|  =((trip k) "inline")
            =((trip k) "content")
            =((trip k) "block")
        ==
      (texts v)
    ""
  ==
::
::  +open-group: a client-created group starts at write. It has no
::  channels yet, so nothing is listed until one is created.
::
++  open-group
  |=  [prev=(map @t group-policy) flag=@t]
  ^-  (map @t group-policy)
  (~(put by prev) flag [%write ~])
::
::  +open-channel: grant the new nest the best access the ceiling
::  allows. A hidden group is opened at write and every other nest
::  is hidden, so only the new channel is exposed. A read ceiling
::  stays read.
::
++  open-channel
  |=  [prev=(map @t group-policy) flag=@t nest=@t existing=(list @t)]
  ^-  [pol=(map @t group-policy) access=grant]
  =/  cur  (fall (~(get by prev) flag) hidden-policy)
  ?:  =(ceiling.cur %hide)
    =/  old=(list @t)  (skip existing |=(n=@t =(n nest)))
    =/  hidden=(map @t over)
      %-  malt
      %+  turn  old
      |=  n=@t
      ^-  [@t over]
      [n %hide]
    :-  (~(put by prev) flag [%write hidden])
    %write
  =/  chans  (~(del by channels.cur) nest)
  :-  (~(put by prev) flag ceiling.cur chans)
  (fall (effective ceiling.cur %inherit) %read)
::
::  +apply-edits: merge manage-page edits into ship policy.
::  Inherit deletes the nest key. A group that was absent, and would
::  be the hidden default with no channel keys, stays absent.
::  Unknown groups and non-chat nests are ignored.
::
++  apply-edits
  |=  [edits=(list manage-edit) groups=json prev=(map @t group-policy)]
  ^-  (map @t group-policy)
  ?.  ?=([%o *] groups)  prev
  =/  next
    =/  acc  prev
    |-
    ^-  (map @t group-policy)
    ?~  edits  acc
    $(edits t.edits, acc (apply-one i.edits groups acc))
  (drop-fresh-hides next prev)
::
++  apply-one
  |=  [edit=manage-edit groups=json prev=(map @t group-policy)]
  ^-  (map @t group-policy)
  ?-  -.edit
      %ceil
    =/  grp  (group-of groups flag.edit)
    ?~  grp  prev
    =/  cur  (fall (~(get by prev) flag.edit) hidden-policy)
    (~(put by prev) flag.edit cap.edit channels.cur)
  ::
      %over
    =/  grp  (group-of groups flag.edit)
    ?~  grp  prev
    ?.  (chat-there u.grp nest.edit)  prev
    =/  cur  (fall (~(get by prev) flag.edit) hidden-policy)
    =/  chans
      ?:  =(mode.edit %inherit)
        (~(del by channels.cur) nest.edit)
      (~(put by channels.cur) nest.edit mode.edit)
    (~(put by prev) flag.edit ceiling.cur chans)
  ==
::
++  chat-there
  |=  [grp=json nest=@t]
  ^-  ?
  ?.  =((kind-of nest) 'chat')  %.n
  =/  ch  (ogot grp 'channels')
  ?~  ch  %.n
  ?.  ?=([%o *] u.ch)  %.n
  (~(has by p.u.ch) nest)
::
++  drop-fresh-hides
  |=  [next=(map @t group-policy) orig=(map @t group-policy)]
  ^-  (map @t group-policy)
  %+  roll  ~(tap by next)
  |=  [[flag=@t pol=group-policy] acc=(map @t group-policy)]
  ?:  ?&  =(~ (~(get by orig) flag))
          =(pol hidden-policy)
      ==
    acc
  (~(put by acc) flag pol)
::
++  cords-at
  |=  [jon=json key=@t]
  ^-  (list @t)
  =/  got  (ogot jon key)
  ?~  got  ~
  ?.  ?=([%a *] u.got)  ~
  %+  murn  p.u.got
  |=  item=json
  ^-  (unit @t)
  ?.  ?=([%s *] item)  ~
  `p.item
::
::  +admin-sects: roles this ship holds that are also in the group's
::  admin bloc, from the fleet/cabals JSON scry.
::
++  admin-sects
  |=  [grp=json our=@t]
  ^-  (set @t)
  =/  bloc  (silt (cords-at grp 'bloc'))
  =/  fleet  (fall (ogot grp 'fleet') [%o ~])
  =/  seat  (fall (ogot fleet our) [%o ~])
  =/  sects  (silt (cords-at seat 'sects'))
  (~(int in bloc) sects)
::
++  is-admin
  |=  [grp=json our=@t]
  ^-  ?
  !=(~ (admin-sects grp our))
::
++  writer-set
  |=  sects=(set @t)
  ^-  (set @tas)
  %-  silt
  %+  murn  ~(tap in sects)
  |=  s=@t
  ^-  (unit @tas)
  =/  run
    %-  mule
    |.  (scan (trip s) sym)
  ?:(?=(%| -.run) ~ `p.run)
::
++  parse-term
  |=  name=@t
  ^-  (unit @tas)
  ?.  ((sane %tas) name)  ~
  =/  run
    %-  mule
    |.  (scan (trip name) sym)
  ?:(?=(%| -.run) ~ `p.run)
::
++  parse-priv
  |=  t=@t
  ^-  (unit ?(%public %private %secret))
  ?:  =(t 'public')   `%public
  ?:  =(t 'private')  `%private
  ?:  =(t 'secret')   `%secret
  ~
::
++  parse-flag
  |=  flag=@t
  ^-  (unit [@p @tas])
  =/  run
    %-  mule
    |.  (scan (trip flag) ;~(plug ;~(pfix sig fed:ag) ;~(pfix fas sym)))
  ?:(?=(%| -.run) ~ `p.run)
::
++  flag-cord
  |=  [ship=@p name=@tas]
  ^-  @t
  (rap 3 (scot %p ship) '/' name ~)
::
++  nest-cord
  |=  [ship=@p name=@tas]
  ^-  @t
  (rap 3 'chat/' (flag-cord ship name) ~)
::
++  group-of
  |=  [jon=json flag=@t]
  ^-  (unit json)
  ?.  ?=([%o *] jon)  ~
  (~(get by p.jon) flag)
::
++  nest-names
  |=  grp=json
  ^-  (list @t)
  =/  ch  (ogot grp 'channels')
  ?~  ch  ~
  ?.  ?=([%o *] u.ch)  ~
  ~(tap in ~(key by p.u.ch))
::
::  Nouns that nest in the live %group-command and %channel-action-2
::  marks. Empty readers means every member can read.
::
++  group-command
  |=  [name=@tas title=@t description=@t priv=?(%public %private %secret)]
  [%create name [title description '' ''] priv [~ ~] ~]
::
++  channel-action
  |=  $:  name=@tas
          ship=@p
          gname=@tas
          title=@t
          description=@t
          writers=(set @tas)
      ==
  [%create %chat name [ship gname] title description ~ ~ writers]
--
