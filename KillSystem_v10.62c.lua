--[[
    杀戮系统 v10.63 [手机飞行修复 + 反作弊扩展 + 暴力功能扩展]
    更新（v10.62c → v10.63 大规模修复 + 新增）：

    1. 修复手机端飞行无法上升：
       - 根本原因：手机端 MouseButton1Down/Up/Leave 在某些机型上 事件不稳定
         MouseButton1Up 与 MouseLeave 同时触发会误清状态，导致上升按钮失效
       - 修复方案：
         * 改用 InputBegan/InputEnded + UserInputType.Touch 直接监听触摸事件
         * 按钮 Active=true 让其在按住期间持续响应
         * 按钮尺寸加大 80→96 像素，便于手指点击
         * 新增多点触摸支持（同时按摇杆+上升按钮可同时生效）
         * 新增"按住判定"：触摸开始后即使手指轻微移动也保持按下状态

    2. 修复手机端快捷键已开启显示不明显：
       - 原问题：开启/关闭只靠 BackgroundTransparency 0.2/0.5 区分，手机端对比度太弱
       - 修复方案：
         * 开启时背景改为霓虹绿色 + 白色发光边框
         * 关闭时背景改为深灰色 + 无边框
         * 新增点击缩放反馈（按下时短暂缩小到 0.9，松开恢复）
         * 触摸阈值 15→25 像素，避免轻微移动误判为拖动
         * SyncShortcuts 同步颜色与边框，状态实时刷新

    3. 优化电脑端启动延迟：
       - BootSequence 打字机速度 25ms→12ms，模块加载 180ms→80ms
       - 整体开场动画从 ~5s 缩短到 ~2s
       - Heartbeat 处理器仅在 GodMode 开启时执行血量覆盖
       - 心跳循环检测从 1Hz 改为 2Hz 但仅在需要时执行
       - 减少无功能时的空转循环 wait(2) → wait(5)

    4. 新增 14 个圣奥里反作弊封禁拦截功能（基于反编译脚本深度搜索）：
       - AntiHandcuff_Enabled: 拦截 handcuff/handcuffsOpener InvokeServer（防被铐）
       - AntiSit_Enabled: 拦截 sit InvokeServer（防强制坐下）
       - AntiCharRot_Enabled: 拦截 charRot/charRotType 强制转向
       - AntiFocusCamera_Enabled: 拦截 focusCamera 强制凝视
       - AntiStalkPlayer_Enabled: 拦截 stalkPlayer 被凝视
       - AntiCharPivotTo_Enabled: 拦截 charPivotTo 强制传送
       - AntiCharCheckpoint_Enabled: 拦截 charCheckpoint 强制传送
       - AntiGetRidOfSitting_Enabled: 拦截 getRidOfPlayerSittingOnYou 被踢下座位
       - AntiFreezeIdle_Enabled: 拦截 freezeIdleAnimation 强制空闲动画
       - AntiPlayEmote_Enabled: 拦截 playEmote 强制表情
       - AntiRagdollEnhanced_Enabled: 拦截 ragdoll FireServer（防强制Ragdoll）
       - AntiEjectEnhanced_Enabled: 拦截 eject 强制弹下车
       - AntiTow_Enabled: 拦截 towing/towStolen 车辆被拖走
       - AntiVehicleTheft_Enabled: 拦截 stealVehicle 车辆被偷
       - AntiClientKick_Enabled: Hook Player:Kick() 防止客户端被踢

    5. 新增 10 个暴力功能（基于 FireServer/InvokeServer 协议主动调用）：
       - MassHandcuff_Enabled: 给附近所有玩家发 handcuff（铐住所有人）
       - MassArrest_Enabled: 给附近所有玩家发 arrestClient 没收物品
       - MassRagdoll_Enabled: 给附近所有玩家发 ragdoll（强制倒地）
       - MassEject_Enabled: 把附近所有车里的玩家 eject 出来
       - MassStun_Enabled: 组合拳 ragdoll+eject+sit（群体眩晕）
       - VehicleDestroySpam_Enabled: 给附近所有车辆发 vehicle:damage:100（摧毁）
       - VehicleStopAll_Enabled: 给附近所有车发 vehicle:stop（强制停车）
       - VehicleLockAll_Enabled: 给附近所有车发 vehicle:lock=true（强制上锁）
       - BulletStorm_Enabled: 每帧向最近玩家发 50 发 bullet（弹幕风暴）
       - ForceFling_Enabled: 给附近所有玩家发 applyImpulse（强制击飞）

    更新（v10.62b → v10.62c 修复）：
    1. 修复用户反馈"穿墙关闭车辆依然可以穿墙"
       - 根本原因：Stepped 处理器在 Noclip 开启时每帧给车辆 CanCollide=false
         但 Noclip_Enabled 回调只在开关变化时触发一次
         如果用户在 Noclip 开启期间上车/下车，新驾驶的车辆不会被保存到
         State.NoclipOriginalProps，导致关闭时无法恢复
       - 修复方案：
         * 监听 Noclip 状态变化，关闭时启动 3 秒恢复窗口
         * 智能恢复函数 RestorePartCollision：
           - 跳过 HumanoidRootPart 和 Head（默认 CanCollide=false）
           - 跳过 Accessory 部件（帽子/头发/饰品，避免碰撞盒变大）
           - 仅恢复 BasePart 实体部件
         * Stepped 在恢复窗口内持续恢复：
           - 玩家自身所有部件
           - 当前驾驶的车辆
           - 附近 30 米内最近 5 辆车
         * 持续 3 秒确保覆盖所有上下车情况
    2. 同时增强 Noclip_Enabled 回调：
       - 开启时不仅保存玩家部件，还保存当前驾驶车辆的所有部件
       - 关闭时统一从 State.NoclipOriginalProps 恢复

    更新（v10.62 → v10.62b 紧急修复）：
    1. 修复用户反馈"开启脚本后会让我碰撞变大"
       - 根本原因：v10.62 在 Noclip 关闭后用 Stepped 监听器每帧强制设置
         CanCollide=true，但这会激活所有 Accessory（帽子/头发/饰品等）的碰撞盒
         导致角色碰撞体积异常变大
       - 实际上 Noclip_Enabled 回调中已有正确的恢复机制（line ~734 的
         State.NoclipOriginalProps：开启时保存原始碰撞状态，关闭时恢复）
       - 修复：移除错误的 Stepped 强制恢复逻辑，仅依赖原有的恢复机制

    更新（v10.61 → v10.62 大规模修复）：

    1. 修复 GodModeHumanoidHardening 服务器仍判定死亡：
       - 之前 SetStateEnabled(Dead, false) 不够，因为 characterDied 函数会主动调用
         Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
       - 修复：Hook __namecall 拦截 Humanoid:ChangeState(Dead) 调用
         改为 ChangeState(GettingUp) 防止进入死亡状态
       - 修复：Heartbeat 每帧强制 Health=MaxHealth（高频覆盖服务端扣血）
       - 持续保持 MaxHealth=99999

    2. 修复 GodModeBulletProof 免疫枪伤无效：
       - 之前只在 Character 上设置 BulletProof
       - 修复：同时在 LocalPlayer + Character + HumanoidRootPart 上设置
       - 三个位置双重保险

    3. 修复穿墙关闭后车辆仍可穿墙：
       - 原因：Noclip 关闭后 CanCollide=false 残留未恢复
       - 修复：Stepped 监听 Noclip_Enabled=false 时恢复 CanCollide=true
       - 注意：HumanoidRootPart/Head 默认 CanCollide=false，不恢复这两者

    4. 修复 GodMode 让通缉消除进度不显示：
       - 原因：GodMode 让服务端检测异常状态后停止 WantedPoints 衰减
       - 修复：定期清除 FreezeWantedLevel 属性（仅当未开启 AntiArrest 时）
       - 注意：这是部分缓解，根本原因是服务端权威

    5. 修复近战无冷却无效：
       - 原因：ForEachWeaponConfig 路径错误，找不到 Config 模块
       - 修复：使用正确路径 Stuff.Weapons.<ID>.<WeaponName>.Config
       - 真实路径已通过反编译验证

    6. 修复武器强化完全无效果：
       - 原因：武器 Config 路径错误 + 弹药存储在 IntValue 而非 ModuleScript
       - 修复：
         * ForEachWeaponConfigV62 使用正确路径
         * 同时修改 Tool.Config 文件夹中的 IntValue（Ammo/TotalAmmo）
         * 自动换弹不再依赖触发 Reload 事件，直接补满 IntValue
       - 反编译验证：弹药在 p12.Config.Ammo.Value / p12.Config.TotalAmmo.Value

    7. 修复 BrutalDamage 伤害完全是虚的：
       - v10.61 已改用 FireServer("damage", t) 真正发包
       - v10.62 进一步修正：target 必须是 Player 实例（不是 Character）
       - 同时移除目标的 BulletProof/SpawnProtection 让伤害生效

    8. 修复刷钱完全无效：
       - 反编译分析发现：paycheck 是服务端权威，客户端无法注入
       - paycheck 事件只是 UI 通知，真正 Cash 由 AccessData 表推送
       - 改为真正可能有效的途径：
         * MoneySpam_catchFish: 高频 InvokeServer("catchFish")
         * MoneySpam_cashDropPickup: 拾取地图上所有 CashDrop 实例
         * MoneySpam_localVisualOnly: 本地视觉显示大量现金（不真实增加）
       - 保留 talkToMission/questCompleted/revive（虽可能无效但不影响）

    9. 新增车辆速度修改功能：
       - VehicleSpeedHack_Enabled: 修改车辆最大速度
       - 实现：
         * 修改 ReplicatedStorage.Stuff.Vehicles.*.Config.MAX_SPEED
         * 关闭已生成车辆的 SpeedLimiter IntValue
         * 设置 _Chassis.Center.LinearVelocity.MaxForce = huge
       - 反编译验证：t.curMaxSpeed = math.floor(0.5 + Config.MAX_SPEED / velocityToMph)

    10. 飞行功能说明：
        - Fly_Enabled 和 SACFly_Enabled 一直保留在移动菜单中
        - 用户可能误以为被删除，实际可用
        - Fly: BodyVelocity + BodyGyro
        - SACFly: BodyPosition + BodyGyro 设置 SAC=true 骗过反作弊

    更新（v10.60 → v10.61 大规模重写）：

    1. 修复 GodModeHumanoidHardening 服务器仍判定死亡：
       - 原因：之前只在血量低于30%时恢复，服务端死亡检测太快
       - 修复：改为高频(10Hz)持续设置 Health=MaxHealth，覆盖服务端扣血
       - 新增：Hook Humanoid.Died 事件防止死亡回调触发
       - 新增：Hook HealthChanged 立即恢复血量
       - 新增：CharacterAdded 监听器，新角色立即硬化

    2. 修复 BrutalDamage 暴力伤害完全是虚的：
       - 原因：v10.53 改为"直接修改目标Humanoid.Health"，但客户端对其他玩家
         Humanoid 没有网络所有权，修改无效
       - 修复：Melee/Ranged 攻击循环全部改用 FireServer("damage", t) 真正发包
       - damage 包格式：{ bodyParts, shotCode, target, pos, damageFactor, bulletProofTool=false }
       - 同时移除目标的 BulletProof / SpawnProtection 属性让伤害生效

    3. 修复 ClientStamina/ClientFood 在反作弊被开启：
       - 用户反馈："无限饥饿/体力在反作弊那就被开启了，我要的是直接客户端设置不是发包"
       - 原因：之前用 ForceStamina/ForceFood 走 FireServer("setStaminaOrFood") 触发反作弊
       - 修复：ClientStamina/ClientFood 改为纯客户端设置：
         * 设置 Framework.Core.stamina/food = 100
         * 设置 LocalPlayer:SetAttribute("Stamina"/"Food", 100)
         * 调用本地 setCoreStaminaOrFood（不发包）
       - BootSequence 模块清单移除所有"Anti-Cheat Module"项
         改为仅显示真正自动开启的客户端功能

    4. 修复 Noclip 穿墙导致车辆掉地底：
       - 原因：Noclip 会扫描 50 米内所有车辆设置 CanCollide=false
         导致玩家未驾驶的车辆失去碰撞→掉入地底
       - 修复：只处理玩家自身部件 + 当前驾驶的车辆（seat连接的）
         不再扫描附近其他车辆

    5. 修复 UnflipVehicle 翻车复位无效：
       - 原因：使用 PivotTo 直接 CFrame，但客户端对未驾驶的车辆没有网络所有权
       - 修复：改用 FireServer("unflipVehicle", car) + 本地 PivotTo 兜底

    6. 修复刷钱功能无效（说明）：
       - catchFish/talkToMission/questCompleted/revive 现已正确发包
       - 如果仍无效果，说明服务端对调用频率/参数有验证
       - 可尝试开启 Debug 模式查看具体响应

    7. 新增 8 个车辆功能（基于反编译 FireServer("vehicle", action) 协议）：
       - VehicleLockSpam：车锁刷（锁/解锁附近所有车辆）
       - VehicleCleanSpam：车辆清洁刷（cleanliness=100）
       - HeadlightSpam：大灯闪烁刷（高频切换headlights）
       - SirenSpam：警笛刷（高频切换muteSiren）
       - HornSpam：喇叭刷（高频切换indicator）
       - VehicleAntiSteal：防车盗窃（持续通知isPlayersVehicleStolen=false）
       - VehicleLockProtect：车辆锁定保护（持续vehicle/lock=true）

    更新（v10.59 → v10.60 升级）：
    1. 修复用户反馈"无敌也是包含枪械伤害"：
       - 原因：枪械伤害走 FireServer("damage",...) 由攻击者发送
         服务端直接扣血，Hook 拦截不到（受害者客户端无法拦截攻击者的调用）
       - 解决方案：设置 BulletProof=true 属性让攻击者的 canCombat 校验失败
       - 新增 GodModeBulletProof_Enabled：循环设置 BulletProof + SpawnProtection 属性
       - 同时设置 SpawnProtection 提供更柔和的拒绝（不触发反作弊告警）
    2. 修复枪械伤害通过 BulletProof 失效时的兜底方案：
       - 新增 GodModeHumanoidHardening_Enabled：Humanoid 状态硬化
         * 禁用 Dead 状态（防死亡）
         * 禁用 Physics 状态（防Ragdoll）
         * BreakJointsOnDeath = false
         * 血量低于30%时强制恢复到满血
         * MaxHealth 提升至 9999
    3. 新增防入狱功能 AntiArrest_Enabled：
       - 监听 OnClientEvent 中的入狱相关事件：
         respawnCharacter / charPivotTo / sit / redBlueTransition / characterIsPhysicallyOccupied
       - respawnCharacter 时立即清除 Arrested 属性防止入狱重生
       - sit 事件时立即起身
       - 持续循环清除 Arrested / PrepareToSetPrisonSentence 属性
    4. 新增防击退功能 AntiKnockback_Enabled：
       - 监听 OnClientEvent 中的 applyImpulse 事件
       - 检测到时立即归零 AssemblyLinearVelocity/AngularVelocity
    5. 新增 4 个刷钱功能：
       - MoneySpam_catchFish: 高频 InvokeServer("catchFish")
       - MoneySpam_talkToMission: 循环 talkToMission(harvested/cargoLoaded/ingredients/playerNearby)
         自动遍历任务ID 1-10
       - MoneySpam_questCompleted: 高频 FireServer("questCompleted") + guideCompleted + tipLearned
         自动遍历任务ID 1-15
       - MoneySpam_revive: 高频 FireServer("revive") 自动复活
    6. 防护菜单新增 5 个开关：
       - 上帝模式-枪械免疫(BulletProof)
       - 上帝模式-Humanoid硬化
       - 防入狱(拦截重生/传送/坐下)
       - 防击退(拦截applyImpulse)
    7. 实用菜单新增 4 个刷钱开关

    更新（v10.58d → v10.59 关键修复）：
    1. 修复 ItemGodmode 拦截失效的根本原因：
       - 之前 Hook 仅拦截 PlayerEvent.FireServer，完全没拦截 PlayerFunc.InvokeServer
       - 但游戏 12+ 个物品消耗走 InvokeServer 通道：
         medicKit（医疗包）/ repairKit（修理包）/ fuelCan（油桶）/ fishingBait（鱼饵）/
         catchFish / refuel / deployParachute（降落伞）/ useLifebuoy（救生圈）/
         spikeStrips（路障）/ placeScene / placeItem / cashDrop / removeGraffiti /
         trafficPaddle / expandLadder / stretcher / shootingRange / miniGolf
       - 用户反馈"物品消耗依然发生"完全符合此分析
    2. 重写 InstallPlayerEventHook：
       - hookmetamethod(__namecall) 现在同时检查 method == "FireServer"(PlayerEvent)
         和 method == "InvokeServer"(PlayerFunc)
       - hookfunction 后备也同时 hook 两个函数
    3. shouldBlock 函数签名改为 (method, self, code, args)：
       - 能区分调用来源（FireServer vs InvokeServer）
       - 针对每个通道应用不同的拦截规则
    4. ItemGodmode 拦截范围扩展：
       - FireServer 通道新增: medicine / throwPhysicsObject / makeSnowball / campfire
       - InvokeServer 通道新增: 19 个物品消耗代码（见上方列表）
       - 复合调用支持: housingEdit(modifyAsset,purchase=true) / arrestClient(searchPlayerConfiscateItems)
    5. 修复 fishingBait 死代码:
       - 原代码把 fishingBait 放在 FireServer 拦截列表，但实际它是 InvokeServer 调用
       - 现已移到 InvokeServer 通道
    6. Debug 模式打印 Hook 状态、各通道拦截是否启用

    关于"重写所有非新增加功能"的说明：
    - 通过深度分析 v10.42 原版，确认以下功能原本就是纯客户端（无 FireServer 版本可恢复）:
      DisableAntiCheat / UnlockGamepasses / DisableWanted / AllowBuyAnyItem /
      ClientStamina / ClientFood / AntiSpawnProtect / HookCanCombat / BypassBulletProof
    - 这些功能在 v10.42 中也是修改本地 GameRules/Core 表，无法影响服务端
    - v10.58d 已添加它们的 FireServer 替代版本：
      * ForceStamina/FireFood → FireServer("setStaminaOrFood",...)
      * PermanentCombat/ForceCombatMode → FireServer("combatMode",true)
      * GodMode/ItemGodmode/AntiCheatReportHook → Hook 拦截（v10.59 已扩展到 InvokeServer）

    更新（v10.58c → v10.58d 修复）：
    1. 修复用户反馈："把新版永久战斗替换为旧版，旧版永久免战斗应该是拦截战斗事件而不是设置为假"
    2. PermanentCombat（永久战斗）从 SetAttribute 改为 FireServer 实现：
       - 旧：LocalPlayer:SetAttribute("CombatMode", true)（v10.53 纯客户端版，实测无效）
       - 新：每30秒 FireServer("combatMode", true)（v10.42 旧版协议，服务端正确响应）
    3. PermanentAntiCombat（永久免战斗）改为事件驱动拦截：
       - 旧：帧循环 SetAttribute("CombatMode", false)（重复发包会重置40秒计时）
       - 新：监听 PlayerEvent.OnClientEvent 中的 "combatMode" 事件
              仅在战斗被触发时（eventName="combatMode" 且 combatMsg 非 nil）发送一次 false
    4. ForceCombatMode（强制战斗模式）也同步恢复为 FireServer 实现
    5. Melee_ForceCombatMode / Melee_SelfAntiCombatMode 同步恢复为 FireServer
    6. 移除所有 SetAttribute('CombatMode') 调用，统一改为 FireServer("combatMode", true/false)

    更新（v10.58b → v10.58c 修复）：
    1. 修复用户反馈："无敌有效不过无消耗物品无效"
       原因：原 ItemGodmode 只屏蔽 degradeItem（耐久损耗）
       实际物品消耗（吃食物/用医疗包/使用道具）走的是 modifyInventory 通道
    2. ItemGodmode 拦截范围扩展为 3 类调用：
       - degradeItem：工具/武器耐久损耗
       - modifyInventory (change > 0)：物品消耗/移除（吃食物、用医疗包、丢道具等）
       - fishingBait：钓鱼饵消耗
    3. shouldBlock 函数重构：接收完整 args 参数，能访问 FireServer 调用的 payload
       可基于参数内容做更精细的拦截判断
    4. 兼容 change 为字符串 "remove"/"consume" 的情况
    5. Debug 模式下打印 Hook 安装状态，方便排查

    更新（v10.58 → v10.58b 紧急修复）：
    1. 修复开场后全场无敌+UI消失的严重问题：
       - GodMode/ItemGodmode/AntiCheatReportHook 默认值从 true 改为 false
         原因：开场自动安装 hookmetamethod(__namecall) 会拦截游戏所有 :FireServer 调用
         导致游戏内部通信被破坏（包括 UI 数据同步、属性更新等），表现为 UI 消失
       - 同时 GodMode 屏蔽 takeDamage 会让玩家免疫所有伤害（看起来无敌）
    2. 所有 Hook 改为懒加载：
       - InstallPlayerEventHook：仅当 GodMode/ItemGodmode/AntiCheatReportHook 任一=true 时安装
       - InstallSilentAimHook：仅当 VapeSilentAim_Enabled=true 时安装
       - InstallDamageInjectorHook：仅当 DamageInjector_Enabled=true 时安装
       防止脚本启动时无条件 hook 干扰游戏
    3. BootSequence 开场动画增加保底机制：
       - 整个动画流程包裹 pcall，任何异常都会强制销毁 bootGui
       - 额外启动 12秒强制销毁定时器，无论动画是否完成都会销毁覆盖层
       防止动画中途出错导致 UI 永久遮挡
    4. BootSequence 模块清单移除 3 个 Hook 项（GodMode/ItemGodmode/AntiCheatReportHook）
       因为它们改为手动开启，不再属于"开场自动加载"
    5. 防护菜单新增 3 个开关：上帝模式、物品无损、反作弊报告屏蔽
       用户可按需手动开启（开启后立即生效，不需要重启脚本）

    更新（v10.57 → v10.58 升级）：
    1. 移植 v10.42 中验证可用的功能：
       - 强制体力(ForceStamina)：高频发包 setStaminaOrFood,stamina=100
       - 强制饱食(ForceFood)：高频发包 setStaminaOrFood,food=100
    2. 新增 7 个暴力枪械功能（基于反编译 Stuff.Weapons.*.Config 分析）：
       - 多发子弹(Weapon_BulletAmount)：任何枪都像散弹一样多发，TR_DIFF=0全中同点
       - 零散射(Weapon_NoSpread)：TR_DIFF=0, SPREAD=0, ACCURACY=0.001
       - 无限射程(Weapon_InfiniteRange)：MAX_DISTANCE=99999
       - 自动换弹(Weapon_AutoReload)：弹夹空时主动Reload+补满弹药
       - 伤害注入(DamageInjector)：Hook damage事件，damageFactor=999+7部位全命中
       - 自动扣机(TriggerBot)：鼠标指向敌人时自动tool:Activate()
       - SilentAim Hook升级版：Hook PlayerEvent.FireServer("bullet")自动修正命中位置为最近敌人头部
    3. DamageInjector / SilentAim 通过 hookmetamethod(__namecall) 拦截 FireServer 调用
    4. 与 v10.57 的 GodMode/ItemGodmode/AntiCheatReportHook Hook 共存（多个Hook链式调用）
    5. 兼容性：所有 Hook 包裹 pcall，hookmetamethod 不支持时自动降级到 hookfunction

    更新（v10.56 → v10.57 升级）：
    1. 不再限定纯客户端实现，加入基于反编译的RemoteEvent/RemoteFunction主动调用
    2. 新增 PlayerEvent.FireServer Hook 系统（hookmetamethod/__namecall 拦截）：
       - GodMode：屏蔽 takeDamage / runOverVictim，免疫环境伤害与车辆碾压
       - ItemGodmode：屏蔽 degradeItem，物品永不损耗
       - AntiCheatReportHook：屏蔽 "14"/"46"/"772"/"121"/"429"/"violation" 全部反作弊自报告
    3. 上述3项默认=true（开场自动开启，无菜单开关），并加入BootSequence动画进度展示
    4. 新增6个服务器端主动调用功能（菜单手动开启）：
       - 防护菜单：防警方拦截（循环 vehicle:policeCanPullOverPlayer=false）
       - 实用菜单：免费特殊工具（装备MDT/Phone/Map/SmartRadio等）
       - 实用菜单：自动钓鱼刷钱（循环 InvokeServer("catchFish")）
       - 实用菜单：自动医疗包（血量低时循环 FireServer("medicine")）
       - 实用菜单：服务器点击传送（Ctrl+Q触发 charPivotTo，绕过客户端传送检测）
       - 实用菜单：凝视最近玩家（F6触发 stalkPlayer，无需staff权限）
    5. Hook系统兼容性：优先 hookmetamethod（主流执行器），后备 hookfunction

    更新（v10.55 → v10.56 升级）：
    1. 修正BootSequence错误分类：SACFly（飞行绕过）是飞行功能而非反作弊，
       已从开场动画反作弊模块清单中移除，并将Config.SACFly_Enabled重置为false（需手动开启）
    2. 秒互动(InstantInteract)已设为默认开启=true，并加入BootSequence开场动画进度展示
       （扫描workspace下所有ProximityPrompt，强制HoldDuration=0）
    3. BootSequence模块清单标题从"ANTI-CHEAT MODULES"改为"CLIENT SYSTEM MODULES"
       （涵盖反作弊+实用功能两类自动启动模块）
    4. 新增8个客户端功能（基于反编译脚本ReplicatedStorage.Stuff.Weapons/GameRules分析）：
       - 战斗菜单：武器连发(RPM=9999)、快速换弹(RELOAD=0)、散弹强化、
         武器伤害覆盖、近战无冷却(REST_TIME=0)
       - 防护菜单：防击飞(AssemblyVelocity上限)、禁用车辆碰撞Ragdoll(GameRules阈值)
       - 实用菜单：快速复活(GameRules.respawnTime=0)
       - 视觉菜单：禁用太阳光晕(SunRaysEffect)
    5. 实现原理：require()缓存共享同一表，客户端篡改GameRules/Config.ModuleScript
       即可影响游戏读取的所有本地状态判定

    更新（v10.54 → v10.55 修复与升级）：
    1. 修复致命语法错误：🔧实用菜单（原1543行）缺失 end) 关闭 CreateSideIcon
    1. 修复致命语法错误：🔧实用菜单（原1543行）缺失 end) 关闭 CreateSideIcon，
       导致整个文件无法编译（错误：Expected 'end' (to close 'function' at line 1543), got <eof>）
    2. 删除菜单中所有反作弊/反反作弊开关：
       - 战斗：防弹衣穿透(BypassBulletProof)、移除出生保护(AntiSpawnProtect)、Hook canCombat
       - 移动：SAC绕过飞行(SACFly)
       - 漏洞：禁用反作弊、解锁所有Gamepass、禁用通缉等级、允许购买任意物品、
              客户端体力、客户端饱食、属性修改(PropertyHack)
    3. 将所有反作弊功能的 Config 默认值改为 true（开场自动开启）
    4. 新增炫酷开场动画 BootSequence：
       - 全屏霓虹渐变背景
       - 系统Logo与版本号打字机动画
       - 逐项显示11个反作弊模块加载进度（每项 [LOADING...] → [ENABLED]）
       - 总进度条同步增长
       - 完成后显示 "ALL SYSTEMS READY" 并淡出
    5. 原"🎯 漏洞"菜单重命名为"🎯 调试"，仅保留屏幕日志与Debug模式开关

    更新（v10.53 → v10.54 修复）：
    1. 修复Aimbot自瞄模块语法错误：移除AutoFire代码时遗留的orphaned end导致块闭合偏移
       错误信息：Expected 'end' (to close 'function' at line 3872), got 'else'; did you forget to close 'then' at line 4058?
       原因：v10.53删除if Config.Aimbot_AutoFire then...end的if语句时保留了end
       修复：移除orphaned end，使if Config.Aimbot_Enabled then...else...end结构正确闭合

    更新（v10.52 → v10.53 纯客户端重写）：
    1. 移除所有FireServer/InvokeServer/OnClientEvent代码
    2. 战斗系统改为直接Humanoid.Health修改（纯客户端）
    3. 战斗模式改为LocalPlayer:SetAttribute
    4. 自伤治疗改为Health=MaxHealth
    5. 无限耐久改为直接修改武器Config模块
    6. VapeSilentAim改为纯相机操控
    7. 反强制转向/面向锁定改为RenderStepped CFrame操控
    8. 反弹出改为客户端监控循环
    9. 翻车复位改为直接CFrame操控
    10. 聚焦相机改为Camera.CFrame操控
    11. 属性修改改为直接Config模块Ammo修改
    12. 防弹衣穿透改为移除BulletProof属性
    13. 移除所有需要FireServer/InvokeServer的功能（共50+个）
    14. 移除已被DisableAntiCheat覆盖的Anti772/Anti121等
    15. 移除无实现的功能（VapeAutoBlock/Scaffold/FastPlace等）
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- 修复：脚本重复执行时销毁旧UI
pcall(function()
    local oldGui = CoreGui:FindFirstChild("KillSystemUI_v10")
    if oldGui then oldGui:Destroy() end
end)
pcall(function()
    local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("KillSystemUI_v10")
    if oldGui then oldGui:Destroy() end
end)
-- 清理旧攻击线容器
pcall(function()
    local oldContainer = workspace:FindFirstChild("KillSystem_AttackLines")
    if oldContainer then oldContainer:Destroy() end
end)

-- 前置声明核心函数
local StartMeleeLoop, StartRangedLoop, ClearLockVisuals, ClearESP, HookWeaponConfig
local ClosePopup  -- 前置声明，供侧栏触发按钮回调使用
local DrawAttackLine, ClearAttackLines  -- 前置声明，供攻击循环与回调使用

-- 启动时强制清理可能残留的旧高亮实例
local function CleanupOrphanVisuals()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") and (obj.Name == "KillSystem_MeleeLock" or obj.Name == "KillSystem_RangedLock") then
            obj:Destroy()
        end
    end
end
CleanupOrphanVisuals()

local Config = {
    -- 近战
    Melee_Enabled = false,
    Melee_Range = 30,
    Melee_Delay = 0.03,
    Melee_HyperThread = false,
    Melee_MultiHit = true,
    Melee_ForceCombatMode = true,
    Melee_SelfAntiCombatMode = false,
    Melee_CheckFriends = false,
    Melee_CheckVisibility = false,
    Melee_TargetNPC = false,
    Melee_AutoPopTires = false,
    Melee_AllowedTeams = {},

    -- 远程
    Ranged_Enabled = false,
    Ranged_Range = 1000,
    Ranged_Delay = 0.05,
    Ranged_HyperThread = true,
    Ranged_AutoHeadshot = true,
    Ranged_MultiBullet = true,
    Ranged_WallBang = false,
    Ranged_CheckFriends = false,
    Ranged_CheckVisibility = false,
    Ranged_TargetNPC = false,
    Ranged_AutoPopTires = false,
    Ranged_NoRecoil = true,
    Ranged_AllowedTeams = {},

    -- 实用工具
    ESP_Enabled = false,
    InstantInteract_Enabled = true,    -- 秒互动：ProximityPrompt/HoldDuration=0（开场自动开启）
    Tool_InfiniteDurability = false,
    TestMode = false,

    -- 全图互动
    GlobalInteract_Enabled = false,

    -- 防御系统（基于反编译事件协议）
    NoKilledVisual_Enabled = false,      -- 反死亡视觉：禁用KilledColorCorrection
    AntiRagdoll_Enabled = false,         -- 反强制Ragdoll：拦截ragdoll事件
    FastGetUp_Enabled = false,           -- 快速起身：监控物理Ragdoll状态
    AntiEject_Enabled = false,           -- 反强制弹出：拦截eject事件后重新上车
    AntiCharHidden_Enabled = false,      -- 反强制隐藏：拦截characterHidden事件
    CleanLightingEffects_Enabled = false, -- 持续清理视觉效果

    -- 转向控制（基于charRot协议）
    AntiForceRotation_Enabled = false,   -- 反强制转向：用摄像机朝向覆盖charRot
    FaceLockedTarget_Enabled = false,    -- 面向锁定目标：锁定时强制面向目标

    -- 防弹衣穿透
    BypassBulletProof_Enabled = true,   -- 防弹衣穿透：移除目标BulletProof属性（开场自动开启）

    -- 战斗状态控制（独立分类）
    PermanentCombat_Enabled = false,    -- 永久战斗模式：FireServer("combatMode",true) 每30秒
    PermanentAntiCombat_Enabled = false, -- 永久免战模式：事件驱动拦截 OnClientEvent 中的 combatMode 事件
    AutoEquipWeapon_Enabled = false,    -- 自动装备武器：Humanoid:EquipTool

    -- 攻击线绘制
    DrawMeleeLine_Enabled = false,      -- 近战攻击线：从玩家位置到目标位置
    DrawRangedLine_Enabled = false,     -- 远程攻击线：从枪口到命中位置

    -- 自动消耗物品（基于modifyInventory协议）
    -- 运动系统（基于VapeV4模式）
    Speed_Enabled = false,              -- 速度增强：修改WalkSpeed
    Speed_Value = 50,                   -- 速度值
    JumpPower_Enabled = false,          -- 跳跃增强：修改JumpPower
    JumpPower_Value = 100,              -- 跳跃力值
    Fly_Enabled = false,                -- 飞行：使用BodyVelocity
    Fly_Speed = 50,                     -- 飞行速度
    InfiniteJump_Enabled = false,       -- 无限跳跃
    Noclip_Enabled = false,             -- 穿墙
    NoFall_Enabled = false,             -- 防露落伤害

    -- 渲染系统（基于VapeV4模式）
    Fullbright_Enabled = false,         -- 全亮：提升环境亮度
    AntiBlind_Enabled = false,          -- 防致盲：禁用闪光弹效果

    -- 实用工具（基于VapeV4模式）
    AutoRespawn_Enabled = false,        -- 自动重生
    ClickTeleport_Enabled = false,      -- 点击传送：鼠标点击位置传送

    -- 自瞄系统（全参数可调）
    Aimbot_Enabled = false,             -- 自瞄开关
    Aimbot_FOV = 150,                   -- FOV范围（像素半径）
    Aimbot_Smoothness = 0.3,            -- 平滑度（0=瞬锁，1=极慢）
    Aimbot_LockHead = true,             -- 锁定头部（false=锁定HumanoidRootPart）
    Aimbot_TargetMode = 1,              -- 目标选择：1=最近距离 2=最低血量 3=最近屏幕中心
    Aimbot_Prediction = 0,              -- 弹道预测（0=关闭，单位秒）
    Aimbot_VisibilityCheck = false,     -- 可见性检测（穿墙不锁）
    Aimbot_AutoFire = false,            -- 自动开火（锁定后自动发射）
    Aimbot_RightClickOnly = true,       -- 仅右键锁定（false=自动锁定）
    Aimbot_ShowFOV = true,              -- 显示FOV圆圈
    Aimbot_DamageFactor = 1.5,          -- 伤害倍率（1=正常，1.5=爆头）
    Aimbot_WallBang = false,            -- 穿墙伤害（不检测可见性直接伤害）
    Aimbot_FriendsCheck = false,        -- 好友检测（不瞄准好友）
    Aimbot_NPC = false,                 -- 瞄准NPC

    -- 安全漏洞利用（基于反编译审计）
    SACFly_Enabled = false,            -- SAC绕过飞行：BodyPosition设置SAC=true（飞行功能，需手动开启）
    SelfHeal_Enabled = false,           -- 自伤治疗：直接设置Health=MaxHealth
    SelfHeal_Interval = 1,              -- 治疗间隔（秒）

    -- 强力暴力利用（v10.35新增）

    -- 纯客户端权威（v10.36新增 - 真正生效）
    DisableAntiCheat_Enabled = true,   -- 禁用反作弊：GameRules.disableAntiCheat=true（开场自动开启）
    UnlockGamepasses_Enabled = true,   -- 解锁所有Gamepass（开场自动开启）
    DisableWanted_Enabled = true,      -- 禁用通缉等级（开场自动开启）
    AllowBuyAnyItem_Enabled = true,    -- 允许购买任意物品（开场自动开启）
    ClientStamina_Enabled = true,      -- 客户端体力：直接设置Core.stamina=100（开场自动开启）
    ClientFood_Enabled = true,         -- 客户端饱食：直接设置Core.food=100（开场自动开启）
    ClientWalkSpeed_Enabled = false,    -- 客户端移速：修改GameRules WalkSpeed
    ClientWalkSpeed_Value = 50,         -- 移速值
    ClientSwimSpeed_Enabled = false,    -- 客户端游泳速度
    ClientSwimSpeed_Value = 50,         -- 游泳速度值

    -- 移动端漏洞利用整合（v10.37新增）
    -- VapeV4暴力功能搬运（v10.38新增）
    VapeKillaura_Enabled = false,       -- Killaura：近战范围自动攻击全图
    VapeKillaura_Range = 18,            -- Killaura范围
    VapeKillaura_Delay = 0.1,           -- Killaura延迟
    VapeSilentAim_Enabled = false,      -- SilentAim：静默瞄准（子弹追踪）
    VapeSilentAim_FOV = 200,            -- SilentAim FOV
    VapeVelocity_Enabled = false,       -- Velocity：防击退（抵消速度）
    VapeVelocity_X = 1,                 -- X轴速度倍率
    VapeVelocity_Y = 0,                 -- Y轴速度倍率
    VapeVelocity_Z = 1,                 -- Z轴速度倍率
    VapeReach_Enabled = false,          -- Reach：增加攻击距离
    VapeReach_Distance = 20,            -- Reach距离
    VapeHitbox_Enabled = false,         -- Hitbox：扩大命中箱
    VapeHitbox_Size = 10,               -- Hitbox大小

    -- 自定义参数（v10.38新增）

    -- 更多新功能（v10.38新增）
    UnflipVehicle_Enabled = false,      -- 自动翻车复位：FireServer("unflipVehicle", car) + 本地PivotTo
    VehicleLockSpam_Enabled = false,   -- 车锁刷：交替发送lock/unlock给附近所有车辆
    VehicleCleanSpam_Enabled = false,  -- 车辆清洁刷：对所有车辆发送cleanliness=100
    HeadlightSpam_Enabled = false,      -- 大灯闪烁刷：高频切换车辆headlights
    SirenSpam_Enabled = false,         -- 警笛刷：高频切换车辆muteSiren
    HornSpam_Enabled = false,           -- 喇叭刷：高频切换车辆indicator
    VehicleAntiSteal_Enabled = false,   -- 防车盗窃：持续通知附近车辆未被盗
    VehicleLockProtect_Enabled = false, -- 车辆锁定：持续锁定附近车辆
    -- 真正无敌与暴力杀戮（v10.39新增）
    HookCanCombat_Enabled = true,      -- Hook canCombat：绕过战斗限制（开场自动开启）
    BrutalDamage_Enabled = false,       -- 暴力伤害：全身体部位+最大倍率
    BrutalDamage_Factor = 10,           -- 伤害倍率（1-100）
    BrutalDamage_MultiCount = 5,        -- 多重伤害次数
    ForceCombatMode_Enabled = false,    -- 强制战斗模式：高频发送combatMode,true
    AntiSpawnProtect_Enabled = true,   -- 移除出生保护：清除SpawnProtection属性（开场自动开启）
    AllBodyParts_Enabled = false,       -- 全身体部位打击
    MaxDamageFactor_Enabled = false,    -- 最大伤害倍率（999x）

    -- 纯客户端终极功能（v10.40新增 - 真正生效）
    FOVModify_Enabled = false,          -- FOV修改：设置Core.initialFOV
    FOVModify_Value = 120,              -- FOV值
    NoJumpLimit_Enabled = false,        -- 无跳跃限制：isJumpEnabled=true
    -- [v10.45修复] 移除重复的AntiRagdoll_Enabled定义（已在第101行定义）
    ClientNotify_Enabled = false,       -- 客户端通知：调用Core.notify
    ClientNotify_Text = "Hello from KillSystem!", -- 通知文本
    DebugMode_Enabled = false,          -- Debug模式：打印功能状态
    InfiniteOxygen_Enabled = false,     -- 无限氧气
    CameraFOV_Enabled = false,          -- 相机FOV
    CameraFOV_Value = 120,              -- 相机FOV值
    AntiBlur_Enabled = false,           -- 防模糊
    AntiColorCorrection_Enabled = false,-- 防色彩校正
    ForceDay_Enabled = false,           -- 强制白天
    ForceNight_Enabled = false,         -- 强制夜晚
    NoFog_Enabled = false,              -- 无雾
    Brightness_Enabled = false,         -- 亮度增强
    Brightness_Value = 3,               -- 亮度值

    -- 手机端日志（v10.41新增）
    ScreenLog_Enabled = false,          -- 手机端屏幕日志
    ScreenLog_MaxLines = 10,            -- 最大显示行数

    -- ======== 圣奥里(San Aurie)游戏专用功能（v10.50新增） ========
    -- 防护功能

    -- 实用功能

    -- 漏洞功能
    PropertyHack_Enabled = true,       -- 属性修改：直接修改武器Config.Ammo（开场自动开启）
    PropertyHack_Value = 999,           -- 属性修改值

    -- [v10.56新增] 武器配置批量覆盖（基于反编译ReplicatedStorage.Stuff.Weapons.*.Config）
    Weapon_RapidFire = false,           -- 武器连发：require(Config).RPM = 9999
    Weapon_FastReload = false,          -- 快速换弹：require(Config).RELOAD_TIME = 0
    Weapon_ShotgunBoost = false,        -- 散弹强化：BULLET_AMOUNT=50, TR_DIFF=0
    Weapon_MaxDamage = false,           -- 武器伤害覆盖（本地视觉）：DAMAGE = 999
    Weapon_NoMeleeCooldown = false,    -- 近战无冷却：REST_TIME = 0

    -- [v10.56新增] 防护扩展（基于GameRules与AssemblyVelocity）
    AntiFling_Enabled = false,          -- 防击飞：限制AssemblyLinear/AngularVelocity
    AntiCrashRagdoll_Enabled = false,   -- 禁用车辆碰撞Ragdoll：GameRules.crash阈值=99999

    -- [v10.56新增] 实用扩展
    FastRespawn_Enabled = false,        -- 快速复活：GameRules.respawnTime/deadTime=0

    -- [v10.56新增] 视觉扩展
    NoSunRays_Enabled = false,          -- 禁用太阳光晕：移除SunRaysEffect

    -- [v10.57新增] 服务器端 Hook 拦截类（被动防护，默认关闭防止干扰游戏）
    -- [v10.58b修正] 默认值改为 false，避免开场后全场无敌/UI消失等副作用
    GodMode_Enabled = false,           -- 上帝模式：Hook 屏蔽 takeDamage/runOverVictim
    ItemGodmode_Enabled = false,      -- 物品无损：Hook 屏蔽 degradeItem
    AntiCheatReportHook_Enabled = false, -- 反作弊报告Hook：屏蔽 "14"/"46"/"772"/"121"/"429"/"violation"

    -- [v10.57新增] 服务器端主动调用类（默认关闭，菜单手动开启）
    AntiPullOver_Enabled = false,       -- 防警方拦截：循环 FireServer("vehicle","policeCanPullOverPlayer",false)
    FreeTools_Enabled = false,          -- 免费特殊工具：循环装备 MDT/Phone/Map/SmartRadio 等
    CatchFishSpam_Enabled = false,      -- 自动钓鱼刷钱：循环 InvokeServer("catchFish")
    FreeHealSpam_Enabled = false,       -- 自动治疗刷血：循环 FireServer("medicine")
    ServerClickTeleport_Enabled = false, -- 服务器端点击传送：Ctrl+Q 触发 charPivotTo
    StalkNearestPlayer_Enabled = false, -- 凝视最近玩家：F6 触发 stalkPlayer

    -- [v10.58新增] 无限体力/饥饿（服务器端高频发包）
    ForceStamina_Enabled = false,        -- 强制体力：高频发包 setStaminaOrFood,stamina=100
    ForceFood_Enabled = false,          -- 强制饱食：高频发包 setStaminaOrFood,food=100

    -- [v10.58新增] 暴力枪械扩展
    Weapon_BulletAmount_Enabled = false, -- 多发子弹：任何枪都像散弹一样多发
    Weapon_BulletAmount_Value = 20,     -- 多发子弹数量
    Weapon_NoSpread_Enabled = false,    -- 零散射：TR_DIFF=0, SPREAD=0, ACCURACY=0.001
    Weapon_InfiniteRange_Enabled = false, -- 无限射程：MAX_DISTANCE=99999
    Weapon_AutoReload_Enabled = false,  -- 自动换弹：弹夹空时主动Reload+补满
    DamageInjector_Enabled = false,     -- 伤害注入：Hook damage事件，damageFactor=999+多部位命中
    TriggerBot_Enabled = false,         -- 自动扳机：鼠标指向敌人时自动开火

    -- [v10.60新增] GodMode 增强：BulletProof属性 + Humanoid硬化
    -- 解决用户反馈"无敌也是包含枪械伤害"
    -- 原因：枪械伤害走 FireServer("damage",...) 由攻击者发送，服务端直接扣血
    --       Hook 拦截不到。需要设置 BulletProof 属性让攻击者的 canCombat 校验失败
    GodModeBulletProof_Enabled = false, -- GodMode增强：循环设置 BulletProof=true 属性（免疫枪械伤害）
    GodModeHumanoidHardening_Enabled = false, -- GodMode硬化：禁用Dead/Physics状态+BreakJointsOnDeath=false

    -- [v10.60新增] 防入狱：拦截 OnClientEvent 中的入狱相关事件
    AntiArrest_Enabled = false,        -- 防入狱：拦截 respawnCharacter/charPivotTo/sit/redBlueTransition
    AntiKnockback_Enabled = false,     -- 防击退：拦截 applyImpulse（防子弹/爆炸击退）

    -- [v10.60新增] 刷钱功能
    -- [v10.62修正] paycheck 不可注入（服务端权威），移除无效功能
    -- 改为真正可能有效的途径
    MoneySpam_catchFish = false,       -- 自动钓鱼刷钱：高频 InvokeServer("catchFish")
    MoneySpam_cashDropPickup = false,  -- 拾取地图上所有 CashDrop 实例（无需靠近）
    MoneySpam_localVisualOnly = false, -- 仅本地视觉显示大量现金（不真实增加）
    MoneySpam_talkToMission = false,   -- 任务奖励刷：循环 talkToMission(harvested/cargoLoaded/ingredients)
    MoneySpam_questCompleted = false,  -- 任务完成刷：高频 FireServer("questCompleted")
    MoneySpam_revive = false,          -- 自动复活：高频 FireServer("revive")，复活后可领奖励

    -- [v10.61新增] 车辆扩展功能（基于反编译 FireServer("vehicle", action, args) 协议）
    -- 注意：以下功能会持续发包，请按需开启

    -- [v10.62新增] 车辆速度修改
    VehicleSpeedHack_Enabled = false,  -- 车辆速度修改：覆盖 Config.MAX_SPEED + 关闭 SpeedLimiter
    VehicleSpeedHack_Value = 300,       -- 目标最大速度（mph）

    -- ======== [v10.63新增] 圣奥里反作弊封禁拦截系统 ========
    -- 基于 1(2).txt 反编译脚本深度搜索的真实 FireServer/InvokeServer 协议
    -- 这些功能被动拦截游戏服务端发来的"强制动作"事件

    -- 玩家被动事件拦截（防止被他人强制操作）
    AntiHandcuff_Enabled = false,           -- 防被铐：拦截 handcuff/handcuffsOpener InvokeServer
    AntiSit_Enabled = false,                -- 防强制坐下：拦截 sit InvokeServer
    AntiCharRot_Enabled = false,            -- 防强制转向：拦截 charRot/charRotType
    AntiFocusCamera_Enabled = false,        -- 防强制凝视：拦截 focusCamera FireServer
    AntiStalkPlayer_Enabled = false,        -- 防被凝视：拦截 stalkPlayer
    AntiCharPivotTo_Enabled = false,        -- 防强制传送：拦截 charPivotTo
    AntiCharCheckpoint_Enabled = false,     -- 防检查点传送：拦截 charCheckpoint
    AntiGetRidOfSitting_Enabled = false,    -- 防被踢下座位：拦截 getRidOfPlayerSittingOnYou
    AntiFreezeIdle_Enabled = false,         -- 防强制空闲动画：拦截 freezeIdleAnimation
    AntiPlayEmote_Enabled = false,          -- 防强制表情：拦截 playEmote
    AntiRagdollEnhanced_Enabled = false,    -- 防强制Ragdoll：拦截 ragdoll FireServer
    AntiEjectEnhanced_Enabled = false,      -- 防被弹下车：拦截 eject
    AntiTow_Enabled = false,                -- 防车辆被拖：拦截 towing/towStolen
    AntiVehicleTheft_Enabled = false,       -- 防车辆被偷：拦截 stealVehicle

    -- Hook 类防护（不依赖 OnClientEvent，直接 Hook 函数）
    AntiClientKick_Enabled = false,         -- 防客户端踢出：Hook Player:Kick() 拦截
    AntiServerShutdown_Enabled = false,     -- 防服务端关闭消息：Hook BindToClose

    -- ======== [v10.63新增] 暴力功能扩展 ========
    -- 基于 FireServer/InvokeServer 协议主动调用，对附近所有玩家/车辆进行群体攻击
    -- 注意：以下功能会高频发包，仅在私密服或测试环境使用

    MassHandcuff_Enabled = false,           -- 群体铐住：给附近所有玩家发 handcuff
    MassHandcuff_Range = 50,                -- 群体铐住范围
    MassArrest_Enabled = false,             -- 群体逮捕：给附近所有玩家发 arrestClient 没收物品
    MassArrest_Range = 50,                  -- 群体逮捕范围
    MassRagdoll_Enabled = false,            -- 群体倒地：给附近所有玩家发 ragdoll
    MassRagdoll_Range = 80,                 -- 群体倒地范围
    MassEject_Enabled = false,              -- 群体弹下：把附近所有车里的玩家 eject 出来
    MassEject_Range = 100,                  -- 群体弹下范围
    MassStun_Enabled = false,               -- 群体眩晕：组合拳 ragdoll+eject+sit
    MassStun_Range = 80,                    -- 群体眩晕范围

    -- 车辆暴力功能
    VehicleDestroySpam_Enabled = false,     -- 摧毁附近车辆：vehicle:damage:100
    VehicleDestroySpam_Range = 200,         -- 摧毁范围
    VehicleStopAll_Enabled = false,         -- 强制停车：vehicle:stop 给附近所有车
    VehicleStopAll_Range = 200,             -- 停车范围
    VehicleLockAll_Enabled = false,         -- 强制锁车：vehicle:lock=true 给附近所有车
    VehicleLockAll_Range = 200,             -- 锁车范围

    -- 极端暴力功能
    BulletStorm_Enabled = false,            -- 弹幕风暴：每帧向最近玩家发 50 发 bullet
    BulletStorm_Range = 500,                -- 弹幕范围
    ForceFling_Enabled = false,             -- 强制击飞：给附近所有玩家发 applyImpulse
    ForceFling_Range = 100,                 -- 击飞范围
}
-- [全局状态与回调中心]
local State = {
    RemoteEvent = nil,
    IsRemoteHooked = false,
    MeleeThreads = {},
    RangedThreads = {},
    AutoHideThread = nil,
    Shortcuts = {},
    ShortcutsByConfigKey = {},  -- 新增：按configKey索引快捷键，用于状态同步
    SideIcons = {},              -- 新增：侧栏图标引用，用于主题切换时同步颜色
    IsPlacingShortcut = false,
    CurrentActionToBind = nil,
    PlacementCapture = nil,     -- 新增：全屏捕获按钮引用
    CombatModeTick = 0,
    ESPObjects = {},
    VisualRegistry = { Melee = {}, Ranged = {} },
    Connections = {},
    AttackLines = {},  -- 新增：当前活跃的攻击线实例注册表，用于关闭时清理
    -- [v10.51新增] 手机端飞行适配
    IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
    MobileFlyUp = false,      -- 手机端虚拟上升按钮状态
    MobileFlyDown = false,    -- 手机端虚拟下降按钮状态
    FlyMobileBtnUp = nil,     -- 上升按钮引用
    FlyMobileBtnDown = nil,   -- 下降按钮引用
    FlyMobileFrame = nil,     -- 按钮容器引用
    GlobalCallbacks = {
        Melee_Enabled = function(val)
            if val then StartMeleeLoop() else
                for _, t in ipairs(State.MeleeThreads) do pcall(task.cancel, t) end
                State.MeleeThreads = {}
                ClearLockVisuals("KillSystem_MeleeLock")
            end
        end,
        Ranged_Enabled = function(val)
            if val then StartRangedLoop() else
                for _, t in ipairs(State.RangedThreads) do pcall(task.cancel, t) end
                State.RangedThreads = {}
                ClearLockVisuals("KillSystem_RangedLock")
            end
        end,
        TestMode = function(val) print("[System] 测试开关状态改变 ->", val) end,
        ESP_Enabled = function(val) if not val then ClearESP() end end,
        DrawMeleeLine_Enabled = function(val) if not val then ClearAttackLines() end end,
        DrawRangedLine_Enabled = function(val) if not val then ClearAttackLines() end end,
        Ranged_NoRecoil = function(val)
            local char = LocalPlayer.Character
            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") or (tool:IsA("Model") and tool:FindFirstChild("Handle")) then
                        HookWeaponConfig(tool)
                    end
                end
            end
        end,
        Speed_Enabled = function(val)
            if not val then
                -- 恢复默认速度
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    pcall(function() char.Humanoid.WalkSpeed = 16 end)
                end
            end
        end,
        JumpPower_Enabled = function(val)
            if not val then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    pcall(function() char.Humanoid.UseJumpPower = false end)
                    pcall(function() char.Humanoid.JumpPower = 50 end)
                end
            end
        end,
        -- [v10.51增强] Fly_Enabled回调：清理飞行+管理手机端虚拟按钮
        Fly_Enabled = function(val)
            if not val then
                -- 清理飞行用的BodyVelocity
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local bv = char.HumanoidRootPart:FindFirstChild("KillSystem_FlyBV")
                    if bv then bv:Destroy() end
                    local bg = char.HumanoidRootPart:FindFirstChild("KillSystem_FlyBG")
                    if bg then bg:Destroy() end
                end
            end
            -- 手机端：飞行开启时显示虚拟上下按钮，关闭时隐藏
            if State.IsMobile then
                if val then
                    CreateMobileFlyButtons()
                else
                    DestroyMobileFlyButtons()
                end
            end
        end,
        Noclip_Enabled = function(val)
            if val then
                -- [v10.51修复] 开启穿墙前，保存每个部件的原始碰撞状态
                -- [v10.62c修复] 同时保存当前驾驶车辆的部件状态（关闭时需要恢复）
                State.NoclipOriginalProps = {}
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            State.NoclipOriginalProps[part] = {
                                CanCollide = part.CanCollide,
                                CollisionGroup = part.CollisionGroup
                            }
                        end
                    end
                    -- 同时保存当前驾驶的车辆（如果有seat连接）
                    local seat = char:FindFirstChild("Seat")
                    if seat and seat:IsA("Weld") and seat.Part1 then
                        local vehicle = seat.Part1.Parent
                        if vehicle then
                            for _, part in ipairs(vehicle:GetDescendants()) do
                                if part:IsA("BasePart") and not State.NoclipOriginalProps[part] then
                                    State.NoclipOriginalProps[part] = {
                                        CanCollide = part.CanCollide,
                                        CollisionGroup = part.CollisionGroup
                                    }
                                end
                            end
                        end
                    end
                end
            else
                -- [v10.51修复] 关闭穿墙时，恢复原始碰撞状态（而非盲目设为true）
                -- 之前的问题：对所有部件（包括帽子/头发/饰品等Accessory）设CanCollide=true
                -- 导致Accessory碰撞盒被激活，角色碰撞体积异常变大
                -- [v10.62c修复] 同时恢复车辆的 CanCollide（之前关闭时漏掉了车辆）
                -- 导致用户反馈"穿墙关闭车辆依然可以穿墙"
                local char = LocalPlayer.Character
                if char then
                    -- 优先使用保存的原始值恢复（包括玩家自身和车辆）
                    if State.NoclipOriginalProps then
                        for part, props in pairs(State.NoclipOriginalProps) do
                            if part and part.Parent then
                                pcall(function() part.CanCollide = props.CanCollide end)
                                pcall(function() part.CollisionGroup = props.CollisionGroup end)
                            end
                        end
                        State.NoclipOriginalProps = nil
                    else
                        -- 没有保存值时的安全恢复：只恢复主身体部件，跳过Accessory
                        local mainParts = {
                            Head = true, HumanoidRootPart = true,
                            LeftArm = true, RightArm = true,
                            LeftLeg = true, RightLeg = true,
                            Torso = true, UpperTorso = true, LowerTorso = true,
                            LeftHand = true, RightHand = true,
                            LeftFoot = true, RightFoot = true,
                            LeftUpperArm = true, RightUpperArm = true,
                            LeftLowerArm = true, RightLowerArm = true,
                            LeftUpperLeg = true, RightUpperLeg = true,
                            LeftLowerLeg = true, RightLowerLeg = true,
                        }
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                -- 跳过Accessory内的部件（帽子/头发/饰品等不应参与碰撞）
                                local isInAccessory = false
                                local parent = part.Parent
                                while parent and parent ~= char do
                                    if parent:IsA("Accessory") or parent:IsA("Hat") or parent.Name == "Accessory" then
                                        isInAccessory = true
                                        break
                                    end
                                    parent = parent.Parent
                                end
                                if isInAccessory then
                                    pcall(function() part.CanCollide = false end)
                                elseif mainParts[part.Name] then
                                    pcall(function() part.CanCollide = true end)
                                    pcall(function() part.CollisionGroup = "Character" end)
                                else
                                    -- 其他部件（如工具等）恢复为不碰撞
                                    pcall(function() part.CanCollide = false end)
                                end
                            end
                        end
                    end
                end
            end
        end,
        -- [v10.45修复] 补充缺失的Fullbright_Enabled回调（原代码缺少函数声明）
        Fullbright_Enabled = function(val)
            if not val then
                -- 恢复默认亮度
                pcall(function()
                    game.Lighting.Brightness = 2
                    game.Lighting.ClockTime = 14
                    game.Lighting.FogEnd = 100000
                    local atm = game.Lighting:FindFirstChildOfClass("Atmosphere")
                    if atm then atm.Haze = 0 end
                end)
            end
        end,
        -- [v10.51增强] SACFly_Enabled回调：清理飞行+管理手机端虚拟按钮
        SACFly_Enabled = function(val)
            if not val then
                -- 清理SAC飞行用的BodyPosition/BodyGyro
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local bp = char.HumanoidRootPart:FindFirstChild("KillSystem_SACFlyBP")
                    if bp then bp:Destroy() end
                    local bg = char.HumanoidRootPart:FindFirstChild("KillSystem_SACFlyBG")
                    if bg then bg:Destroy() end
                    if char:FindFirstChild("Humanoid") then
                        char.Humanoid.PlatformStand = false
                    end
                end
            end
            -- 手机端：飞行开启时显示虚拟上下按钮，关闭时隐藏
            if State.IsMobile then
                if val then
                    CreateMobileFlyButtons()
                else
                    DestroyMobileFlyButtons()
                end
            end
        end,
        -- 修复：关闭VapeV4功能时恢复状态
        VapeHitbox_Enabled = function(val)
            if not val then
                -- 恢复所有玩家的Hitbox大小
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        if root and root:IsA("BasePart") then
                            root.Size = Vector3.new(2, 2, 1)
                        end
                        local head = player.Character:FindFirstChild("Head")
                        if head and head:IsA("BasePart") then
                            head.Size = Vector3.new(2, 1, 1)
                        end
                    end
                end
            end
        end,
        FOVModify_Enabled = function(val)
            if not val then
                local camera = workspace.CurrentCamera
                if camera then camera.FieldOfView = 70 end
            end
        end,
        CameraFOV_Enabled = function(val)
            if not val then
                local camera = workspace.CurrentCamera
                if camera then camera.FieldOfView = 70 end
            end
        end,
        NoJumpLimit_Enabled = function(val)
            if not val then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = 50
                end
            end
        end,
        -- 修复：关闭渲染功能时恢复
        ForceDay_Enabled = function(val)
            if not val then
                game.Lighting.Brightness = 2
            end
        end,
        ForceNight_Enabled = function(val)
            if not val then
                game.Lighting.Brightness = 2
            end
        end,
        NoFog_Enabled = function(val)
            if not val then
                game.Lighting.FogEnd = 1000
            end
        end,
        Brightness_Enabled = function(val)
            if not val then
                game.Lighting.Brightness = 2
            end
        end,
        AntiBlur_Enabled = function(val)
            if not val then
                -- 恢复所有BlurEffect（除我们自己的）
                for _, child in ipairs(game.Lighting:GetChildren()) do
                    if child.Name ~= "KillSystem_Blur" and child:IsA("BlurEffect") then
                        child.Enabled = true
                    end
                end
            end
        end,
        AntiColorCorrection_Enabled = function(val)
            if not val then
                -- 恢复所有ColorCorrectionEffect
                for _, child in ipairs(game.Lighting:GetChildren()) do
                    if child:IsA("ColorCorrectionEffect") then
                        child.Enabled = true
                    end
                end
            end
        end,
        VapeReach_Enabled = function(val)
            if val then
                Config.Melee_Range = Config.VapeReach_Distance
            else
                Config.Melee_Range = 30  -- 恢复默认近战范围
            end
        end,
        NoFall_Enabled = function(val)
            if not val then
                -- 清理NoFall的BodyVelocity
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local bv = char.HumanoidRootPart:FindFirstChild("KillSystem_NoFallBV")
                    if bv then bv:Destroy() end
                end
                -- 恢复fallRagdollEnabled
                local core = GetFrameworkCore()
                if core then
                    core.fallRagdollEnabled = true
                end
            end
        end,
    }
}

local function GenerateNeonTheme()
    local h1 = math.random()
    local h2 = (h1 + 0.15) % 1
    return {
        C1 = Color3.fromHSV(h1, 0.8, 1),
        C2 = Color3.fromHSV(h2, 0.9, 1),
        Dark = Color3.fromHSV(h1, 0.5, 0.1),
        Darker = Color3.fromHSV(h1, 0.5, 0.05),
        Background = Color3.fromHSV(h1, 0.5, 0.15)
    }
end

local Theme = GenerateNeonTheme()

-- 修复：复用已存在的UIGradient，避免重复实例累积
local function ApplyGradient(guiObj)
    local grad = guiObj:FindFirstChildOfClass("UIGradient")
    if not grad then
        grad = Instance.new("UIGradient")
        grad.Parent = guiObj
    end
    grad.Color = ColorSequence.new(Theme.C1, Theme.C2)
    grad.Rotation = math.random(0, 360)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillSystemUI_v10"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = "KillSystem_Blur"
BlurEffect.Size = 0
BlurEffect.Parent = Lighting

-- ==========================================
-- [手机端飞行虚拟按钮系统 - v10.51新增]
-- 手机端没有键盘WASD/Space/Shift，需要：
-- 1. 用游戏内置摇杆(Humanoid.MoveDirection)读取前后左右方向
-- 2. 用虚拟按钮控制上升(Space)/下降(Shift)
-- ==========================================

-- 创建手机端飞行虚拟按钮（上升↑ + 下降↓）
-- [v10.51修复] 只使用基础UI组件，避免UIStroke/UICorner/GothamBold等新API不兼容问题
-- [v10.63重写] 修复手机飞行无法上升：
--   1. 改用 InputBegan/InputEnded + UserInputType.Touch 直接监听触摸事件
--   2. 按钮 Active=true 让其在按住期间持续响应（不被其他UI抢占）
--   3. 按钮尺寸加大 80→96 像素，便于手指点击
--   4. 多点触摸支持（同时按摇杆+上升按钮可同时生效）
--   5. 触摸开始后即使手指轻微移动也保持按下状态
function CreateMobileFlyButtons()
    -- 防止重复创建
    if State.FlyMobileFrame and State.FlyMobileFrame.Parent then return end

    local frame = Instance.new("Frame")
    frame.Name = "KillSystem_MobileFly"
    frame.Size = UDim2.new(0, 140, 0, 230)
    frame.Position = UDim2.new(1, -160, 0.5, -115)
    frame.BackgroundTransparency = 1
    frame.Parent = ScreenGui

    -- 上升按钮
    local btnUp = Instance.new("TextButton")
    btnUp.Name = "FlyUp"
    btnUp.Size = UDim2.new(1, 0, 0, 96)
    btnUp.Position = UDim2.new(0, 0, 0, 0)
    btnUp.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    btnUp.BackgroundTransparency = 0.3
    btnUp.Text = "▲ UP"
    btnUp.TextColor3 = Color3.new(1, 1, 1)
    btnUp.TextSize = 28
    btnUp.Font = Enum.Font.SourceSansBold
    btnUp.AutoButtonColor = false  -- [v10.63] 关闭自动颜色变化，自定义反馈
    btnUp.Active = true  -- [v10.63] 关键：Active=true 让按钮在按住期间持续响应
    btnUp.BorderSizePixel = 2
    btnUp.BorderColor3 = Color3.fromRGB(0, 255, 128)
    btnUp.Parent = frame
    Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 12)

    -- 下降按钮
    local btnDown = Instance.new("TextButton")
    btnDown.Name = "FlyDown"
    btnDown.Size = UDim2.new(1, 0, 0, 96)
    btnDown.Position = UDim2.new(0, 0, 0, 134)
    btnDown.BackgroundColor3 = Color3.fromRGB(200, 80, 0)
    btnDown.BackgroundTransparency = 0.3
    btnDown.Text = "▼ DN"
    btnDown.TextColor3 = Color3.new(1, 1, 1)
    btnDown.TextSize = 28
    btnDown.Font = Enum.Font.SourceSansBold
    btnDown.AutoButtonColor = false
    btnDown.Active = true  -- [v10.63] 关键：Active=true
    btnDown.BorderSizePixel = 2
    btnDown.BorderColor3 = Color3.fromRGB(255, 128, 0)
    btnDown.Parent = frame
    Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 12)

    -- 提示标签
    local hint = Instance.new("TextLabel")
    hint.Name = "Hint"
    hint.Size = UDim2.new(1, 0, 0, 28)
    hint.Position = UDim2.new(0, 0, 0, 100)
    hint.BackgroundTransparency = 1
    hint.Text = "摇杆=方向\n按钮=升降"
    hint.TextColor3 = Color3.fromRGB(220, 220, 220)
    hint.TextSize = 13
    hint.Font = Enum.Font.SourceSans
    hint.Parent = frame

    -- [v10.63关键修复] 使用 InputBegan/InputEnded 替代 MouseButton1Down/Up/Leave
    -- 解决手机端 MouseButton1Up 与 MouseLeave 同时触发导致状态被误清的问题
    -- 同时支持 UserInputType.Touch（手机）和 MouseButton1（PC测试）
    local function bindHoldButton(btn, stateKey, pressedColor, releasedColor)
        -- 按下：开始按住状态
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
               or input.UserInputType == Enum.UserInputType.MouseButton1 then
                State[stateKey] = true
                btn.BackgroundTransparency = 0.1
                btn.BorderColor3 = pressedColor
                -- 缩放反馈
                TweenService:Create(btn, TweenInfo.new(0.08), {Size = UDim2.new(0.95, 0, 0, 96)}):Play()
            end
        end)

        -- 松开：结束按住状态
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
               or input.UserInputType == Enum.UserInputType.MouseButton1 then
                State[stateKey] = false
                btn.BackgroundTransparency = 0.3
                btn.BorderColor3 = releasedColor
                TweenService:Create(btn, TweenInfo.new(0.08), {Size = UDim2.new(1, 0, 0, 96)}):Play()
            end
        end)

        -- [v10.63] 兼容旧版 MouseButton1Click 事件（部分执行器只触发这个）
        -- 不重置 state，仅作视觉反馈
        btn.MouseButton1Click:Connect(function()
            -- 这里不修改 state，因为 InputBegan/InputEnded 已经处理
            -- 仅作为兜底视觉反馈
        end)
    end

    bindHoldButton(btnUp, "MobileFlyUp",
        Color3.fromRGB(150, 255, 200),  -- 按下时边框颜色
        Color3.fromRGB(0, 255, 128)     -- 松开时边框颜色
    )
    bindHoldButton(btnDown, "MobileFlyDown",
        Color3.fromRGB(255, 200, 100),
        Color3.fromRGB(255, 128, 0)
    )

    -- 保存引用
    State.FlyMobileBtnUp = btnUp
    State.FlyMobileBtnDown = btnDown
    State.FlyMobileFrame = frame

    if ScreenLog then ScreenLog("飞行: 手机端按钮已显示（v10.63 Touch版）") end
end

-- 销毁手机端飞行虚拟按钮
function DestroyMobileFlyButtons()
    State.MobileFlyUp = false
    State.MobileFlyDown = false
    if State.FlyMobileFrame then
        pcall(function() State.FlyMobileFrame:Destroy() end)
        State.FlyMobileFrame = nil
        State.FlyMobileBtnUp = nil
        State.FlyMobileBtnDown = nil
    end
end

-- ==========================================
-- [原生协议Hook与武器系统]
-- ==========================================
function HookWeaponConfig(tool)
    if not tool then return end
    local cfgModule = tool:FindFirstChild("Config")
    if not cfgModule then return end

    local success, cfg = pcall(require, cfgModule)
    if success and cfg and cfg.GUN then
        if Config.Ranged_NoRecoil then
            cfg.RECOIL = 0
            cfg.TR_DIFF = 0
            cfg.ACCURACY = 0.001
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") or (child:IsA("Model") and child:FindFirstChild("Handle")) then
            task.wait(0.1)
            HookWeaponConfig(child)
        end
    end)
end)

task.spawn(function()
    local char = LocalPlayer.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") or (tool:IsA("Model") and tool:FindFirstChild("Handle")) then
                HookWeaponConfig(tool)
            end
        end
    end
end)

local function FetchRemote()
    if State.RemoteEvent then return State.RemoteEvent end
    local success, result = pcall(function() return ReplicatedStorage:WaitForChild("Remote", 3):WaitForChild("PlayerEvent", 3) end)
    if success and result then
        State.RemoteEvent = result
        return result
    end
    return nil
end


-- [v10.53] 无限耐久：直接修改武器Config模块
task.spawn(function()
    while true do
        if Config.Tool_InfiniteDurability then
            local char = LocalPlayer.Character
            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA('Tool') or (tool:IsA('Model') and tool:FindFirstChild('Handle')) then
                        local cfgModule = tool:FindFirstChild('Config')
                        if cfgModule then
                            local success, cfg = pcall(require, cfgModule)
                            if success and cfg and cfg.GUN then
                                pcall(function() cfg.GUN.DURABILITY = 999999 end)
                                pcall(function() cfg.GUN.CURRENT_AMMO = 999999 end)
                                pcall(function() cfg.GUN.RESERVE_AMMO = 999999 end)
                                pcall(function() cfg.GUN.MAGAZINE_SIZE = 999999 end)
                            end
                        end
                    end
                end
            end
            task.wait(1)
        else
            task.wait(2)
        end
    end
end)

-- [v10.53] VapeSilentAim：纯相机操控（无需FireServer Hook）
task.spawn(function()
    while true do
        if Config.VapeSilentAim_Enabled then
            local camera = workspace.CurrentCamera
            if camera then
                local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                local nearestTarget = nil
                local nearestDist = Config.VapeSilentAim_FOV
                local nearestPos = nil

                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild('Head') then
                        if player.Character:FindFirstChild('Humanoid') and player.Character.Humanoid.Health > 0 then
                            local screenPos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                if dist < nearestDist then
                                    nearestDist = dist
                                    nearestTarget = player
                                    nearestPos = player.Character.Head.Position
                                end
                            end
                        end
                    end
                end

                if nearestTarget and nearestPos then
                    local currentCFrame = camera.CFrame
                    local targetCFrame = CFrame.new(currentCFrame.Position, nearestPos)
                    camera.CFrame = currentCFrame:Lerp(targetCFrame, 0.8)
                end
            end
            task.wait(0.01)
        else
            task.wait(0.1)
        end
    end
end)



-- [v10.53] 反强制转向/面向锁定：RenderStepped直接CFrame操控
-- 原方案：Hook UnreliableEvent.FireServer拦截charRot
-- 新方案：在RenderStepped中直接设置HumanoidRootPart的CFrame朝向
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local camera = workspace.CurrentCamera
    if not char or not char:FindFirstChild('HumanoidRootPart') then return end
    local localRoot = char.HumanoidRootPart

    -- 优先级1：面向锁定目标
    if Config.FaceLockedTarget_Enabled then
        local targetRoot = nil
        if Config.Melee_Enabled then
            for targetChar, _ in pairs(State.VisualRegistry.Melee) do
                if targetChar and targetChar.Parent and targetChar:FindFirstChild('HumanoidRootPart') then
                    targetRoot = targetChar.HumanoidRootPart
                    break
                end
            end
        end
        if not targetRoot and Config.Ranged_Enabled then
            for targetChar, _ in pairs(State.VisualRegistry.Ranged) do
                if targetChar and targetChar.Parent and targetChar:FindFirstChild('HumanoidRootPart') then
                    targetRoot = targetChar.HumanoidRootPart
                    break
                end
            end
        end
        if targetRoot then
            local dir = (targetRoot.Position - localRoot.Position)
            if dir.Magnitude > 0.1 then
                local targetPos = Vector3.new(targetRoot.Position.X, localRoot.Position.Y, targetRoot.Position.Z)
                localRoot.CFrame = CFrame.new(localRoot.Position, targetPos)
            end
        end
    end

    -- 优先级2：反强制转向（用摄像机朝向覆盖）
    if Config.AntiForceRotation_Enabled and not Config.FaceLockedTarget_Enabled and camera then
        local lookVec = camera.CFrame.LookVector
        local targetPos = localRoot.Position + Vector3.new(lookVec.X, 0, lookVec.Z) * 100
        localRoot.CFrame = CFrame.new(localRoot.Position, targetPos)
    end
end)

-- ==========================================
-- [UI 构建逻辑]
-- ==========================================
local SideBarTrigger = Instance.new("TextButton")
SideBarTrigger.Size = UDim2.new(0, 20, 0, 150)
SideBarTrigger.Position = UDim2.new(1, -5, 0.5, -75)
SideBarTrigger.BackgroundColor3 = Theme.Dark
SideBarTrigger.Text = ""
SideBarTrigger.Parent = ScreenGui
Instance.new("UICorner", SideBarTrigger).CornerRadius = UDim.new(0, 8)
ApplyGradient(SideBarTrigger)

local SideBar = Instance.new("ScrollingFrame")
SideBar.Size = UDim2.new(0, 80, 0, 350)
SideBar.Position = UDim2.new(1, 0, 0.5, -175)
SideBar.BackgroundColor3 = Theme.Darker
SideBar.ScrollBarThickness = 3
SideBar.ScrollBarImageColor3 = Theme.C1
SideBar.CanvasSize = UDim2.new(0, 0, 0, 0)
SideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
SideBar.ScrollingDirection = Enum.ScrollingDirection.Y
SideBar.Parent = ScreenGui
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 16)
local sbStroke = Instance.new("UIStroke", SideBar)
sbStroke.Thickness = 2
ApplyGradient(sbStroke)

local SideList = Instance.new("UIListLayout", SideBar)
SideList.Padding = UDim.new(0, 8)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.VerticalAlignment = Enum.VerticalAlignment.Top

local SidePad = Instance.new("UIPadding", SideBar)
SidePad.PaddingTop = UDim.new(0, 8)
SidePad.PaddingBottom = UDim.new(0, 8)

local isSideBarOut = false
local ActivePopup = nil

local function ToggleSideBar(show)
    isSideBarOut = show
    if show then
        TweenService:Create(SideBar, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -90, 0.5, -175)}):Play()
        if State.AutoHideThread then task.cancel(State.AutoHideThread) end
        State.AutoHideThread = task.delay(5, function()
            if isSideBarOut and not (ActivePopup and ActivePopup.Parent) then ToggleSideBar(false) end
        end)
    else
        TweenService:Create(SideBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 0.5, -175)}):Play()
    end
end

-- 修复：弹窗打开时点击侧栏触发按钮应先关闭弹窗，避免UI状态混乱
SideBarTrigger.MouseButton1Click:Connect(function()
    if ActivePopup then ClosePopup() return end
    ToggleSideBar(not isSideBarOut)
end)

-- 修复：ClosePopup改为非yield，避免调用方时序问题；新增showSidebar参数控制是否回弹侧栏
ClosePopup = function(showSidebar)
    if not ActivePopup then return end
    local pop = ActivePopup
    ActivePopup = nil
    TweenService:Create(pop, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(BlurEffect, TweenInfo.new(0.2), {Size = 0}):Play()
    task.delay(0.2, function()
        if pop and pop.Parent then pop:Destroy() end
    end)
    if showSidebar ~= false then
        ToggleSideBar(true)
    end
end

-- 修复：快捷键放置函数，统一管理快捷键创建与注册
-- [v10.63修复] 手机端快捷键已开启显示不明显：
--   1. 开启时背景改为霓虹绿 + 白色发光边框（视觉对比强）
--   2. 关闭时背景为深灰 + 暗淡边框
--   3. 点击缩放反馈（按下时短暂缩小到 0.9）
--   4. 触摸阈值 15→25 像素（手机端更宽容）
--   5. 添加全局 UpdateShortcutVisual 函数统一管理状态显示

-- [v10.63新增] 统一的快捷键视觉更新函数
-- enabled=true 时显示霓虹绿背景+白发光边框，false 时显示深灰+暗边框
function UpdateShortcutVisual(shortcut, enabled)
    if not shortcut or not shortcut.Parent then return end
    if enabled then
        shortcut.BackgroundColor3 = Color3.fromRGB(60, 255, 120)
        shortcut.BackgroundTransparency = 0.1
        shortcut.TextColor3 = Color3.new(0, 0, 0)  -- 黑色文字对比绿色背景
        local stroke = shortcut:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Thickness = 2.5
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0
        end
    else
        shortcut.BackgroundColor3 = Theme.Darker
        shortcut.BackgroundTransparency = 0.6
        shortcut.TextColor3 = Theme.C1
        local stroke = shortcut:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Thickness = 1
            stroke.Color = Color3.fromRGB(80, 80, 100)
            stroke.Transparency = 0.5
        end
    end
end

local function PlaceShortcutAt(pos, key, iconText)
    local shortcut = Instance.new("TextButton")
    shortcut.Size = UDim2.new(0, 54, 0, 54)  -- [v10.63] 50→54 略大便于触摸
    shortcut.Position = UDim2.new(0, pos.X - 27, 0, pos.Y - 27)
    shortcut.BackgroundColor3 = Config[key] and Color3.fromRGB(60, 255, 120) or Theme.Darker
    shortcut.BackgroundTransparency = Config[key] and 0.1 or 0.6
    shortcut.Text = iconText or "⚡"
    shortcut.TextColor3 = Config[key] and Color3.new(0, 0, 0) or Theme.C1
    shortcut.Font = Enum.Font.GothamBold
    shortcut.TextSize = 22
    shortcut.AutoButtonColor = false  -- [v10.63] 关闭自动反馈，自定义缩放反馈
    shortcut.Active = true  -- [v10.63] Active=true 让按钮在按住期间持续响应
    shortcut.Parent = ScreenGui
    Instance.new("UICorner", shortcut).CornerRadius = UDim.new(0, 10)
    -- [v10.63] 添加 UIStroke 边框，开启时为发光白，关闭时为暗灰
    local stroke = Instance.new("UIStroke", shortcut)
    stroke.Thickness = Config[key] and 2.5 or 1
    stroke.Color = Config[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(80, 80, 100)
    stroke.Transparency = Config[key] and 0 or 0.5
    shortcut:SetAttribute("ConfigKey", key)
    table.insert(State.Shortcuts, shortcut)
    if not State.ShortcutsByConfigKey[key] then State.ShortcutsByConfigKey[key] = {} end
    table.insert(State.ShortcutsByConfigKey[key], shortcut)

    local isPressing = false
    local isDragging = false
    local pressTime = 0
    local dragStartPos = nil
    local startUdimPos = nil
    local originalSize = shortcut.Size
    local pressScale = UDim2.new(0, 48, 0, 48)  -- 按下时缩放到 48x48

    shortcut.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            isPressing = true
            isDragging = false
            pressTime = tick()
            dragStartPos = inp.Position
            startUdimPos = shortcut.Position
            -- [v10.63] 按下缩放反馈
            TweenService:Create(shortcut, TweenInfo.new(0.06), {Size = pressScale}):Play()
        end
    end)

    shortcut.InputChanged:Connect(function(inp)
        if isPressing and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            -- [v10.63] 触摸阈值 15→25 像素
            if dragStartPos and (inp.Position - dragStartPos).Magnitude > 25 then
                isDragging = true
                -- 拖动时恢复尺寸
                TweenService:Create(shortcut, TweenInfo.new(0.06), {Size = originalSize}):Play()
                local dx = inp.Position.X - dragStartPos.X
                local dy = inp.Position.Y - dragStartPos.Y
                shortcut.Position = UDim2.new(startUdimPos.X.Scale, startUdimPos.X.Offset + dx, startUdimPos.Y.Scale, startUdimPos.Y.Offset + dy)
            end
        end
    end)

    shortcut.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if not isPressing then return end
            isPressing = false

            -- 恢复原始尺寸
            TweenService:Create(shortcut, TweenInfo.new(0.1, Enum.EasingStyle.Back), {Size = originalSize}):Play()

            local duration = tick() - pressTime
            -- 修复：检查总位移而非isDragging标志，避免轻微移动后isDragging卡true导致切换失效
            -- [v10.63] 阈值 15→25 像素
            local totalDisplacement = dragStartPos and (inp.Position - dragStartPos).Magnitude or 0
            local isClick = totalDisplacement < 25

            if isClick then
                if duration >= 0.8 then
                    -- 长按删除
                    local k = shortcut:GetAttribute("ConfigKey")
                    shortcut:Destroy()
                    for i, sc in ipairs(State.Shortcuts) do if sc == shortcut then table.remove(State.Shortcuts, i) break end end
                    if k and State.ShortcutsByConfigKey[k] then
                        for i, sc in ipairs(State.ShortcutsByConfigKey[k]) do if sc == shortcut then table.remove(State.ShortcutsByConfigKey[k], i) break end end
                    end
                else
                    -- 短按切换
                    if ActivePopup then ClosePopup(false) end
                    Config[key] = not Config[key]
                    if State.GlobalCallbacks[key] then State.GlobalCallbacks[key](Config[key]) end
                    -- [v10.63] 调用统一的视觉更新
                    UpdateShortcutVisual(shortcut, Config[key])
                end
            end
            -- 重置isDragging，防止下次点击继承上次状态
            isDragging = false
        end
    end)
end

-- 修复：快捷键放置模式改用全屏捕获按钮，避免点击穿透；增加视觉提示与ESC取消
local function StartPlacementMode(configKey, iconText)
    State.IsPlacingShortcut = true
    State.CurrentActionToBind = { configKey = configKey, icon = iconText }

    local capture = Instance.new("TextButton")
    capture.Size = UDim2.new(1, 0, 1, 0)
    capture.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    capture.BackgroundTransparency = 0.6
    capture.Text = "点击屏幕任意位置放置快捷键（ESC取消）"
    capture.TextColor3 = Color3.fromRGB(255, 255, 255)
    capture.TextStrokeTransparency = 0
    capture.Font = Enum.Font.GothamBold
    capture.TextSize = 22
    capture.ZIndex = 100
    capture.AutoButtonColor = false
    capture.Parent = ScreenGui
    State.PlacementCapture = capture

    capture.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local bindAction = State.CurrentActionToBind
            State.IsPlacingShortcut = false
            State.CurrentActionToBind = nil
            State.PlacementCapture = nil
            capture:Destroy()
            if bindAction then
                PlaceShortcutAt(pos, bindAction.configKey, bindAction.icon)
            end
            ToggleSideBar(true)
        end
    end)
end

-- ESC取消放置模式
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if State.IsPlacingShortcut and input.KeyCode == Enum.KeyCode.Escape then
        State.IsPlacingShortcut = false
        State.CurrentActionToBind = nil
        if State.PlacementCapture then
            State.PlacementCapture:Destroy()
            State.PlacementCapture = nil
        end
        ToggleSideBar(true)
    end
end)

local function OpenPopup(TitleText, BuildContentFunc)
    -- 修复：打开弹窗时取消侧栏自动隐藏线程，避免无用残留
    if State.AutoHideThread then task.cancel(State.AutoHideThread) State.AutoHideThread = nil end
    if ActivePopup then ClosePopup(false) end
    Theme = GenerateNeonTheme()
    ToggleSideBar(false)

    SideBar.BackgroundColor3 = Theme.Darker
    ApplyGradient(sbStroke)
    ApplyGradient(SideBarTrigger)

    -- 修复：同步侧栏图标颜色至新主题
    for _, icon in ipairs(State.SideIcons) do
        icon.BackgroundColor3 = Theme.Dark
        icon.TextColor3 = Theme.C1
        for _, child in ipairs(icon:GetChildren()) do
            if child:IsA("UIStroke") then
                ApplyGradient(child)
            end
        end
    end

    ActivePopup = Instance.new("Frame")
    ActivePopup.Size = UDim2.new(0, 0, 0, 0)
    ActivePopup.Position = UDim2.new(0.5, 0, 0.5, 0)
    ActivePopup.AnchorPoint = Vector2.new(0.5, 0.5)
    ActivePopup.BackgroundColor3 = Theme.Dark
    ActivePopup.Parent = ScreenGui
    ActivePopup.ClipsDescendants = true
    Instance.new("UICorner", ActivePopup).CornerRadius = UDim.new(0, 16)
    local popStroke = Instance.new("UIStroke", ActivePopup)
    popStroke.Thickness = 2
    ApplyGradient(popStroke)

    TweenService:Create(ActivePopup, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 350, 0, 450)}):Play()
    TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 24}):Play()

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Text = TitleText
    Header.TextColor3 = Theme.C1
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 18
    Header.Parent = ActivePopup

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Theme.Darker
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.C1
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.Parent = ActivePopup
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
    CloseBtn.MouseButton1Click:Connect(function() ClosePopup() end)

    local ContentHolder = Instance.new("ScrollingFrame")
    ContentHolder.Size = UDim2.new(1, -20, 1, -50)
    ContentHolder.Position = UDim2.new(0, 10, 0, 45)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.ScrollBarThickness = 4
    ContentHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentHolder.Parent = ActivePopup

    local ListLayout = Instance.new("UIListLayout", ContentHolder)
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local Pad = Instance.new("UIPadding", ContentHolder)
    Pad.PaddingBottom = UDim.new(0, 10)

    BuildContentFunc(ContentHolder)
end

local function CreateRow(parent, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, height)
    row.BackgroundColor3 = Theme.Darker
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    return row
end

-- 修复：CreateToggle增加wasLongPress标志，避免长按设置快捷键后误触开关切换；增加快捷键透明度同步
local function CreateToggle(parent, name, configKey, icon)
    local row = CreateRow(parent, 40)
    local state = Config[configKey]
    local wasLongPress = false

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 40)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = row

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 45, 0, 22)
    switch.Position = UDim2.new(1, -55, 0.5, -11)
    switch.BackgroundColor3 = Theme.Dark
    switch.AutoButtonColor = false
    switch.Text = ""
    switch.Parent = row
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function UpdateVisual()
        if state then
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.C1}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(1, -19, 0.5, -8)}):Play()
        else
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Dark}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
        end
    end

    local function SyncShortcuts()
        local shortcuts = State.ShortcutsByConfigKey[configKey]
        if shortcuts then
            for _, sc in ipairs(shortcuts) do
                -- [v10.63] 使用统一视觉更新函数，颜色/边框/透明度同步
                UpdateShortcutVisual(sc, state)
            end
        end
    end

    local function ToggleState()
        -- 修复：如果是长按触发的释放，不切换状态
        if wasLongPress then
            wasLongPress = false
            return
        end
        state = not state
        Config[configKey] = state
        UpdateVisual()
        SyncShortcuts()  -- 修复：同步快捷键透明度
        if State.GlobalCallbacks[configKey] then State.GlobalCallbacks[configKey](state) end
    end

    UpdateVisual()
    switch.MouseButton1Click:Connect(ToggleState)

    if icon then
        local pressTime = 0
        local isPressing = false
        switch.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isPressing = true
                pressTime = tick()
                task.delay(0.8, function()
                    if isPressing and tick() - pressTime >= 0.8 then
                        -- 修复：检查弹窗是否仍然有效（防止弹窗已关闭后误触发）
                        if not ActivePopup or not ActivePopup.Parent then return end
                        wasLongPress = true
                        ClosePopup(false)
                        ToggleSideBar(false)
                        StartPlacementMode(configKey, icon)
                    end
                end)
            end
        end)
        switch.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isPressing = false
            end
        end)
    end
    return row
end

local function CreateSlider(parent, name, minVal, maxVal, default, configKey, isFloat)
    local row = CreateRow(parent, 50)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -20, 0, 40)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = row

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.5, -10, 0, 40)
    valLabel.Position = UDim2.new(0.5, 5, 0, 5)
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = Theme.C1
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Font = Enum.Font.GothamMedium
    valLabel.TextSize = 14
    valLabel.Text = isFloat and string.format("%.2f", default) or tostring(default)
    valLabel.Parent = row

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -30, 0, 6)
    barBg.Position = UDim2.new(0, 15, 0, 38)
    barBg.BackgroundColor3 = Theme.Background
    barBg.Parent = row
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-minVal)/(maxVal-minVal), 0, 1, 0)
    fill.BackgroundColor3 = Theme.C1
    fill.Parent = barBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(inputPos)
        local rel = (inputPos.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X
        rel = math.clamp(rel, 0, 1)
        local val = isFloat and (minVal + (maxVal - minVal) * rel) or math.floor(minVal + (maxVal - minVal) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLabel.Text = isFloat and string.format("%.2f", val) or tostring(val)
        Config[configKey] = val
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input.Position) end
    end)
    return row
end

local function CreateMultiSelectList(parent, name, getOptionsFunc, configKey, callback)
    local row = CreateRow(parent, 40)
    local selectedTable = Config[configKey]

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 40)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = row

    local listContainer = Instance.new("Frame")
    listContainer.Size = UDim2.new(1, 0, 0, 0)
    listContainer.Position = UDim2.new(0, 0, 0, 40)
    listContainer.BackgroundTransparency = 1
    listContainer.Parent = row
    listContainer.ClipsDescendants = true

    local listLayout = Instance.new("UIListLayout", listContainer)
    listLayout.Padding = UDim.new(0, 5)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local isExpanded = false
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 30, 0, 30)
    toggleBtn.Position = UDim2.new(1, -40, 0, 5)
    toggleBtn.BackgroundColor3 = Theme.Dark
    toggleBtn.Text = "v"
    toggleBtn.TextColor3 = Theme.C1
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 12
    toggleBtn.Parent = row
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    local function RebuildList()
        for _, child in ipairs(listContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        local teams = getOptionsFunc()
        if #selectedTable == 0 then for _, team in ipairs(teams) do table.insert(selectedTable, team.Name) end end
        local h = 0
        for _, team in ipairs(teams) do
            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(1, -20, 0, 30)
            tBtn.BackgroundColor3 = Theme.Dark
            tBtn.Text = team.Name
            tBtn.TextColor3 = team.TeamColor.Color
            tBtn.Font = Enum.Font.GothamMedium
            tBtn.TextSize = 12
            tBtn.Parent = listContainer
            Instance.new("UICorner", tBtn).CornerRadius = UDim.new(1, 0)
            if table.find(selectedTable, team.Name) ~= nil then tBtn.BackgroundColor3 = Theme.C1 end
            tBtn.MouseButton1Click:Connect(function()
                local idx = table.find(selectedTable, team.Name)
                if idx then
                    table.remove(selectedTable, idx)
                    tBtn.BackgroundColor3 = Theme.Dark
                else
                    table.insert(selectedTable, team.Name)
                    tBtn.BackgroundColor3 = Theme.C1
                end
                callback(selectedTable)
            end)
            h = h + 35
        end
        return h
    end

    toggleBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        if isExpanded then
            local h = RebuildList()
            toggleBtn.Text = "^"
            TweenService:Create(row, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40 + h)}):Play()
            TweenService:Create(listContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, h)}):Play()
        else
            toggleBtn.Text = "v"
            TweenService:Create(row, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40)}):Play()
            TweenService:Create(listContainer, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        end
    end)
end

local function CreateSideIcon(iconText, openFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 48)
    btn.BackgroundColor3 = Theme.Dark
    btn.Text = iconText
    btn.TextColor3 = Theme.C1
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    btn.Parent = SideBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.5, 0)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 2
    ApplyGradient(stroke)
    btn.MouseButton1Click:Connect(openFunc)
    table.insert(State.SideIcons, btn)  -- 新增：注册图标引用
    return btn
end

-- ==========================================
-- [炫酷开场动画 BootSequence - v10.55新增]
-- 全屏覆盖层 + 霓虹渐变背景 + 11个反作弊模块逐项加载进度
-- 完成后自动淡出消失
-- ==========================================
local function BootSequence()
    -- 防止重复执行
    local existing = nil
    pcall(function() existing = CoreGui:FindFirstChild("KillSystem_Boot") end)
    if not existing then
        pcall(function() existing = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("KillSystem_Boot") end)
    end
    if existing then existing:Destroy() end

    local bootGui = Instance.new("ScreenGui")
    bootGui.Name = "KillSystem_Boot"
    bootGui.DisplayOrder = 9999
    bootGui.IgnoreGuiInset = true
    bootGui.ResetOnSpawn = false
    pcall(function() bootGui.Parent = CoreGui end)
    if not bootGui.Parent then bootGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- 主背景（全屏暗色，带霓虹渐变）
    local bgFrame = Instance.new("Frame")
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.Position = UDim2.new(0, 0, 0, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
    bgFrame.BackgroundTransparency = 1
    bgFrame.Parent = bootGui

    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(20, 8, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 8, 24)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(40, 8, 30))
    })
    bgGrad.Rotation = 45
    bgGrad.Parent = bgFrame

    -- 中央容器
    local centerFrame = Instance.new("Frame")
    centerFrame.Size = UDim2.new(0, 560, 0, 500)
    centerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    centerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    centerFrame.BackgroundTransparency = 1
    centerFrame.Parent = bgFrame

    -- 系统标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 54)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = ""
    title.TextColor3 = Color3.fromRGB(255, 80, 200)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 38
    title.Parent = centerFrame
    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = ColorSequence.new(Color3.fromRGB(255, 80, 200), Color3.fromRGB(120, 200, 255))
    titleGrad.Parent = title

    -- 副标题（版本号）
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 22)
    subtitle.Position = UDim2.new(0, 0, 0, 58)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "v10.63  |  MOBILE FLY FIX + ANTI-CHEAT EXT"
    subtitle.TextColor3 = Color3.fromRGB(150, 200, 255)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 14
    subtitle.TextTransparency = 1
    subtitle.Parent = centerFrame

    -- 装饰分隔线
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 2)
    divider.Position = UDim2.new(0, 0, 0, 86)
    divider.BackgroundColor3 = Color3.fromRGB(120, 200, 255)
    divider.BackgroundTransparency = 0.5
    divider.Parent = centerFrame
    local divGrad = Instance.new("UIGradient")
    divGrad.Color = ColorSequence.new(Color3.fromRGB(255, 80, 200), Color3.fromRGB(120, 200, 255), Color3.fromRGB(255, 80, 200))
    divGrad.Parent = divider

    -- 进度条标题
    local progTitle = Instance.new("TextLabel")
    progTitle.Size = UDim2.new(1, 0, 0, 16)
    progTitle.Position = UDim2.new(0, 0, 0, 96)
    progTitle.BackgroundTransparency = 1
    progTitle.Text = ">> INITIALIZING CLIENT SYSTEM MODULES <<"
    progTitle.TextColor3 = Color3.fromRGB(200, 180, 255)
    progTitle.Font = Enum.Font.Code
    progTitle.TextSize = 11
    progTitle.TextTransparency = 1
    progTitle.Parent = centerFrame

    -- 进度条背景
    local progBg = Instance.new("Frame")
    progBg.Size = UDim2.new(1, 0, 0, 10)
    progBg.Position = UDim2.new(0, 0, 0, 116)
    progBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    progBg.BackgroundTransparency = 0.3
    progBg.Parent = centerFrame
    Instance.new("UICorner", progBg).CornerRadius = UDim.new(1, 0)

    -- 进度条填充
    local progFill = Instance.new("Frame")
    progFill.Size = UDim2.new(0, 0, 1, 0)
    progFill.Position = UDim2.new(0, 0, 0, 0)
    progFill.BackgroundColor3 = Color3.fromRGB(255, 80, 200)
    progFill.Parent = progBg
    Instance.new("UICorner", progFill).CornerRadius = UDim.new(1, 0)
    local progGrad = Instance.new("UIGradient")
    progGrad.Color = ColorSequence.new(Color3.fromRGB(255, 80, 200), Color3.fromRGB(120, 200, 255))
    progGrad.Parent = progFill

    -- 百分比文字
    local percentLabel = Instance.new("TextLabel")
    percentLabel.Size = UDim2.new(1, 0, 0, 16)
    percentLabel.Position = UDim2.new(0, 0, 0, 130)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "  0%   [ 0 / 0 MODULES ]"
    percentLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    percentLabel.Font = Enum.Font.Code
    percentLabel.TextSize = 12
    percentLabel.TextXAlignment = Enum.TextXAlignment.Left
    percentLabel.Parent = centerFrame

    -- 模块列表容器
    local modList = Instance.new("Frame")
    modList.Size = UDim2.new(1, 0, 0, 280)
    modList.Position = UDim2.new(0, 0, 0, 154)
    modList.BackgroundTransparency = 1
    modList.Parent = centerFrame
    local modLayout = Instance.new("UIListLayout", modList)
    modLayout.Padding = UDim.new(0, 4)
    modLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- 开场自动加载模块清单（仅显示真正自动开启的功能）
    -- [v10.61修正] 用户反馈"无限饥饿/体力在反作弊那就被开启了"
    -- 移除所有"反作弊模块"项目，改为仅显示已确实自动开启的客户端功能
    -- 这些功能通过 Config 默认值=true 自动启动，无需用户手动操作
    local modules = {
        { name = "Instant Interact System",        icon = "[I]", label = "Zero HoldDuration" },
        { name = "Ranged NoRecoil (GUN Config)",   icon = "[N]", label = "Zero Recoil+Spread" },
    }
    -- 仅当 Config.ClientStamina_Enabled=true 时显示
    if Config.ClientStamina_Enabled then
        table.insert(modules, { name = "Client Stamina (Local)", icon = "[S]", label = "Stamina=100" })
    end
    if Config.ClientFood_Enabled then
        table.insert(modules, { name = "Client Food (Local)", icon = "[F]", label = "Food=100" })
    end
    if Config.PropertyHack_Enabled then
        table.insert(modules, { name = "PropertyHack InfiniteAmmo", icon = "[H]", label = "Ammo Infinite" })
    end
    if Config.BypassBulletProof_Enabled then
        table.insert(modules, { name = "BypassBulletProof", icon = "[P]", label = "Armor Pierced" })
    end
    if Config.AntiSpawnProtect_Enabled then
        table.insert(modules, { name = "AntiSpawnProtect", icon = "[R]", label = "Spawn Protect Off" })
    end
    if Config.HookCanCombat_Enabled then
        table.insert(modules, { name = "Hook canCombat", icon = "[C]", label = "canCombat Hooked" })
    end
    local total = #modules

    local moduleRows = {}
    for i, m in ipairs(modules) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 22)
        row.BackgroundTransparency = 1
        row.Parent = modList

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 30, 1, 0)
        icon.Position = UDim2.new(0, 0, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Text = m.icon
        icon.TextSize = 13
        icon.Font = Enum.Font.Code
        icon.TextColor3 = Color3.fromRGB(120, 120, 150)
        icon.TextXAlignment = Enum.TextXAlignment.Left
        icon.Parent = row

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -150, 1, 0)
        name.Position = UDim2.new(0, 34, 0, 0)
        name.BackgroundTransparency = 1
        name.Text = m.name
        name.TextSize = 13
        name.Font = Enum.Font.Code
        name.TextColor3 = Color3.fromRGB(140, 140, 180)
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = row

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0, 110, 1, 0)
        status.Position = UDim2.new(1, -110, 0, 0)
        status.BackgroundTransparency = 1
        status.Text = "[ PENDING ]"
        status.TextSize = 12
        status.Font = Enum.Font.Code
        status.TextColor3 = Color3.fromRGB(120, 120, 150)
        status.TextXAlignment = Enum.TextXAlignment.Right
        status.Parent = row

        moduleRows[i] = { row = row, status = status, name = name, icon = icon, label = m.label }
    end

    -- 启动主线程动画（非阻塞）
    -- [v10.58b修正] 整个动画流程包裹 pcall，任何中途错误也会确保 bootGui 被销毁
    -- 同时设置 12 秒强制销毁保底，防止卡死导致 UI 永久遮挡
    local animationDone = false

    -- 保底销毁线程：12秒后无论如何都销毁 bootGui
    -- [v10.63] 缩短到 6 秒（动画整体加速，无需 12 秒保底）
    task.delay(6, function()
        if not animationDone then
            pcall(function()
                if bootGui and bootGui.Parent then
                    -- 强制透明后销毁
                    for _, desc in ipairs(bootGui:GetDescendants()) do
                        pcall(function()
                            if desc:IsA("Frame") then desc.BackgroundTransparency = 1 end
                            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                                desc.TextTransparency = 1
                                desc.BackgroundTransparency = 1
                            end
                        end)
                    end
                    if bgFrame then bgFrame.BackgroundTransparency = 1 end
                    task.wait(0.1)
                    bootGui:Destroy()
                end
            end)
            animationDone = true
        end
    end)

    task.spawn(function()
        local ok, err = pcall(function()
            -- 入场动画：背景淡入
            -- [v10.63] 加速：0.4→0.2
            TweenService:Create(bgFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            task.wait(0.2)

            -- 打字机动画：标题
            -- [v10.63] 加速：0.025→0.012
            local fullTitle = "杀 戮 系 统  /  KILL SYSTEM"
            for i = 1, #fullTitle do
                title.Text = string.sub(fullTitle, 1, i)
                task.wait(0.012)
            end
            task.wait(0.08)

            -- 副标题与进度条标题淡入
            -- [v10.63] 加速：0.4→0.2
            TweenService:Create(subtitle, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
            TweenService:Create(progTitle, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
            task.wait(0.15)

            -- 逐项加载反作弊模块
            -- [v10.63] 加速：180ms→80ms per item
            for i = 1, total do
                local r = moduleRows[i]
                -- 状态变为 LOADING
                r.status.Text = "[ LOADING.. ]"
                r.status.TextColor3 = Color3.fromRGB(255, 200, 80)
                r.name.TextColor3 = Color3.fromRGB(220, 220, 255)
                r.icon.TextColor3 = Color3.fromRGB(255, 220, 120)

                -- 同步进度条
                local pct = (i - 1) / total
                TweenService:Create(progFill, TweenInfo.new(0.15), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
                percentLabel.Text = string.format("  %3d%%   [ %d / %d MODULES ]", math.floor(pct * 100), i - 1, total)

                task.wait(0.06 + math.random() * 0.04)

                -- 状态变为 ENABLED
                r.status.Text = "[ ENABLED ]"
                r.status.TextColor3 = Color3.fromRGB(80, 255, 140)
                r.name.TextColor3 = Color3.fromRGB(255, 255, 255)
                r.icon.TextColor3 = Color3.fromRGB(120, 255, 200)

                task.wait(0.04)
            end

            -- 完成动画：进度条100%
            TweenService:Create(progFill, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 1, 0)}):Play()
            percentLabel.Text = string.format("  %3d%%   [ %d / %d MODULES ]", 100, total, total)
            percentLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
            task.wait(0.2)

            -- 显示 "ALL SYSTEMS READY"
            local ready = Instance.new("TextLabel")
            ready.Size = UDim2.new(1, 0, 0, 32)
            ready.Position = UDim2.new(0, 0, 1, -38)
            ready.BackgroundTransparency = 1
            ready.Text = ">>  ALL SYSTEMS READY  <<"
            ready.TextColor3 = Color3.fromRGB(80, 255, 140)
            ready.Font = Enum.Font.GothamBold
            ready.TextSize = 20
            ready.TextTransparency = 1
            ready.Parent = centerFrame
            local readyGrad = Instance.new("UIGradient")
            readyGrad.Color = ColorSequence.new(Color3.fromRGB(80, 255, 140), Color3.fromRGB(120, 200, 255))
            readyGrad.Parent = ready

            TweenService:Create(ready, TweenInfo.new(0.25), {TextTransparency = 0}):Play()

            -- 闪烁效果（[v10.63] 从 3 次减到 2 次加速）
            for i = 1, 2 do
                TweenService:Create(ready, TweenInfo.new(0.08), {TextSize = 22}):Play()
                task.wait(0.08)
                TweenService:Create(ready, TweenInfo.new(0.08), {TextSize = 20}):Play()
                task.wait(0.08)
            end

            task.wait(0.4)

            -- 淡出整个Boot界面
            -- [v10.63] 加速：0.6→0.3
            local tweens = {
                TweenService:Create(bgFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}),
                TweenService:Create(ready, TweenInfo.new(0.3), {TextTransparency = 1}),
                TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}),
                TweenService:Create(subtitle, TweenInfo.new(0.3), {TextTransparency = 1}),
                TweenService:Create(progTitle, TweenInfo.new(0.3), {TextTransparency = 1}),
                TweenService:Create(progBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}),
                TweenService:Create(percentLabel, TweenInfo.new(0.3), {TextTransparency = 1}),
                TweenService:Create(divider, TweenInfo.new(0.3), {BackgroundTransparency = 1}),
            }
            for _, r in ipairs(moduleRows) do
                table.insert(tweens, TweenService:Create(r.status, TweenInfo.new(0.3), {TextTransparency = 1}))
                table.insert(tweens, TweenService:Create(r.name, TweenInfo.new(0.3), {TextTransparency = 1}))
                table.insert(tweens, TweenService:Create(r.icon, TweenInfo.new(0.3), {TextTransparency = 1}))
            end
            for _, t in ipairs(tweens) do t:Play() end
            task.wait(0.4)
        end)

        -- 无论如何都强制销毁 bootGui（防止动画中途异常导致 UI 永久遮挡）
        animationDone = true
        pcall(function() bootGui:Destroy() end)

        if not ok and Config.DebugMode_Enabled then
            print("[KillSystem] BootSequence 动画异常（已强制销毁覆盖层）: " .. tostring(err))
        end
    end)
end

-- ==========================================
-- [侧栏图标 - v10.44 6大分类]
-- ==========================================

CreateSideIcon("⚔️", function()
    OpenPopup("⚔️ 战斗", function(holder)
        -- 近战
        CreateSlider(holder, "发包延迟 (0=极速)", 0, 1, Config.Melee_Delay, "Melee_Delay", true)
        CreateSlider(holder, "攻击范围", 5, 1000, Config.Melee_Range, "Melee_Range", false)
        CreateToggle(holder, "自动攻击", "Melee_Enabled", "⚔️")
        CreateToggle(holder, "多部位打击", "Melee_MultiHit", "🎯")
        CreateToggle(holder, "强制战斗模式", "Melee_ForceCombatMode", "🔥")
        CreateToggle(holder, "好友检测", "Melee_CheckFriends", "🤝")
        CreateToggle(holder, "可见性检测", "Melee_CheckVisibility", "👁️")
        CreateToggle(holder, "瞄准NPC", "Melee_TargetNPC", "👾")
        --- separator ---
        -- 远程
        CreateSlider(holder, "发包延迟 (0=极速)", 0, 1, Config.Ranged_Delay, "Ranged_Delay", true)
        CreateSlider(holder, "攻击范围", 100, 5000, Config.Ranged_Range, "Ranged_Range", false)
        CreateToggle(holder, "自动枪锁", "Ranged_Enabled", "🔫")
        CreateToggle(holder, "仅爆头", "Ranged_AutoHeadshot", "🧠")
        CreateToggle(holder, "散弹多发", "Ranged_MultiBullet", "💥")
        CreateToggle(holder, "子弹穿墙", "Ranged_WallBang", "🧱")
        CreateToggle(holder, "激光无后座", "Ranged_NoRecoil", "🎯")
        --- separator ---
        -- 自瞄
        CreateSlider(holder, "FOV范围（像素）", 30, 500, Config.Aimbot_FOV, "Aimbot_FOV", false)
        CreateSlider(holder, "平滑度（0=瞬锁）", 0, 1, Config.Aimbot_Smoothness, "Aimbot_Smoothness", true)
        CreateToggle(holder, "自瞄开关", "Aimbot_Enabled", "🎯")
        CreateToggle(holder, "锁头部", "Aimbot_LockHead", "🧠")
        CreateToggle(holder, "自动开火", "Aimbot_AutoFire", "🔥")
        CreateToggle(holder, "仅右键锁定", "Aimbot_RightClickOnly", "🖱️")
        CreateToggle(holder, "显示FOV圆圈", "Aimbot_ShowFOV", "⭕")
        --- separator ---
        -- VapeV4暴力功能
        CreateSlider(holder, "Killaura范围", 5, 50, Config.VapeKillaura_Range, "VapeKillaura_Range", false)
        CreateSlider(holder, "Hitbox大小", 1, 50, Config.VapeHitbox_Size, "VapeHitbox_Size", false)
        CreateToggle(holder, "Killaura", "VapeKillaura_Enabled", "🗡️")
        CreateToggle(holder, "SilentAim", "VapeSilentAim_Enabled", "🎯")
        CreateToggle(holder, "Hitbox扩大", "VapeHitbox_Enabled", "📦")
        CreateToggle(holder, "Velocity防击退", "VapeVelocity_Enabled", "🛡️")
        --- separator ---
        -- 暴力杀戮
        CreateSlider(holder, "伤害倍率(1-100)", 1, 100, Config.BrutalDamage_Factor, "BrutalDamage_Factor", false)
        CreateSlider(holder, "多重伤害次数", 1, 20, Config.BrutalDamage_MultiCount, "BrutalDamage_MultiCount", false)
        CreateToggle(holder, "暴力伤害", "BrutalDamage_Enabled", "🔥")
        CreateToggle(holder, "全身体部位", "AllBodyParts_Enabled", "🎯")
        CreateToggle(holder, "最大伤害倍率(999x)", "MaxDamageFactor_Enabled", "💥")
        CreateToggle(holder, "强制战斗模式", "ForceCombatMode_Enabled", "🎪")
        --- separator ---
        -- 武器配置覆盖 [v10.56新增]
        CreateToggle(holder, "武器连发(RPM=9999)", "Weapon_RapidFire", "⚡")
        CreateToggle(holder, "快速换弹(RELOAD=0)", "Weapon_FastReload", "🔄")
        CreateToggle(holder, "散弹强化", "Weapon_ShotgunBoost", "💥")
        CreateToggle(holder, "武器伤害覆盖", "Weapon_MaxDamage", "💀")
        CreateToggle(holder, "近战无冷却", "Weapon_NoMeleeCooldown", "⚔️")
        --- separator ---
        -- [v10.58新增] 暴力枪械扩展
        CreateSlider(holder, "多发子弹数量", 5, 50, Config.Weapon_BulletAmount_Value, "Weapon_BulletAmount_Value", false)
        CreateToggle(holder, "多发子弹(任意枪)", "Weapon_BulletAmount_Enabled", "💥")
        CreateToggle(holder, "零散射", "Weapon_NoSpread_Enabled", "🎯")
        CreateToggle(holder, "无限射程", "Weapon_InfiniteRange_Enabled", "📏")
        CreateToggle(holder, "自动换弹", "Weapon_AutoReload_Enabled", "🔄")
        CreateToggle(holder, "伤害注入(999x)", "DamageInjector_Enabled", "🔥")
        CreateToggle(holder, "自动扣机(指敌人即开火)", "TriggerBot_Enabled", "🔫")
    end)
end)

CreateSideIcon("🛡️", function()
    OpenPopup("🛡️ 防护", function(holder)
        -- 反控制
        CreateToggle(holder, "反死亡视觉", "NoKilledVisual_Enabled", "💀")
        CreateToggle(holder, "反强制Ragdoll", "AntiRagdoll_Enabled", "🤸")
        CreateToggle(holder, "快速起身", "FastGetUp_Enabled", "⬆️")
        CreateToggle(holder, "反强制弹出", "AntiEject_Enabled", "🚗")
        CreateToggle(holder, "反强制隐藏", "AntiCharHidden_Enabled", "👁️")
        CreateToggle(holder, "反强制转向", "AntiForceRotation_Enabled", "🔄")
        CreateToggle(holder, "面向锁定目标", "FaceLockedTarget_Enabled", "🎯")
        --- separator ---
        -- 生存
        CreateToggle(holder, "防坠落伤害", "NoFall_Enabled", "🪂")
        CreateToggle(holder, "无限氧气", "InfiniteOxygen_Enabled", "🫁")
        --- separator ---
        -- [v10.58新增] 无限体力/饥饿（服务器端高频发包）
        CreateToggle(holder, "强制体力(高频发包)", "ForceStamina_Enabled", "⚡")
        CreateToggle(holder, "强制饱食(高频发包)", "ForceFood_Enabled", "🍔")
        --- separator ---
        CreateSlider(holder, "自伤治疗间隔（秒）", 0.5, 10, Config.SelfHeal_Interval, "SelfHeal_Interval", true)
        CreateToggle(holder, "自伤治疗（负伤害）", "SelfHeal_Enabled", "➕")
        --- separator ---
        -- 战斗状态
        CreateToggle(holder, "永久战斗模式", "PermanentCombat_Enabled", "⚔️")
        CreateToggle(holder, "永久免战模式", "PermanentAntiCombat_Enabled", "🕊️")
        CreateToggle(holder, "自动装备武器", "AutoEquipWeapon_Enabled", "🎒")
        --- separator ---
        -- 圣奥里(San Aurie)防护（v10.50新增）
        --- separator ---
        -- [v10.56新增] 防护扩展
        CreateToggle(holder, "防击飞", "AntiFling_Enabled", "🛡️")
        CreateToggle(holder, "禁用车辆碰撞Ragdoll", "AntiCrashRagdoll_Enabled", "🚗")
        --- separator ---
        -- [v10.57新增] 服务器端防护
        CreateToggle(holder, "防警方拦截", "AntiPullOver_Enabled", "🚓")
        --- separator ---
        -- [v10.57新增] FireServer Hook 拦截类（手动开启，谨慎使用）
        CreateToggle(holder, "上帝模式(屏蔽伤害)", "GodMode_Enabled", "💀")
        CreateToggle(holder, "上帝模式-枪械免疫(BulletProof)", "GodModeBulletProof_Enabled", "🛡️")
        CreateToggle(holder, "上帝模式-Humanoid硬化", "GodModeHumanoidHardening_Enabled", "💪")
        CreateToggle(holder, "物品无损(屏蔽消耗)", "ItemGodmode_Enabled", "♾️")
        CreateToggle(holder, "反作弊报告屏蔽(谨慎)", "AntiCheatReportHook_Enabled", "🔇")
        --- separator ---
        -- [v10.60新增] 防入狱/防击退
        CreateToggle(holder, "防入狱(拦截重生/传送/坐下)", "AntiArrest_Enabled", "🔒")
        CreateToggle(holder, "防击退(拦截applyImpulse)", "AntiKnockback_Enabled", "🛡️")
        --- separator ---
        -- [v10.63新增] 圣奥里反作弊封禁拦截系统
        CreateToggle(holder, "防被铐(拦截handcuff)", "AntiHandcuff_Enabled", "🔒")
        CreateToggle(holder, "防强制坐下(拦截sit)", "AntiSit_Enabled", "🪑")
        CreateToggle(holder, "防强制转向(拦截charRot)", "AntiCharRot_Enabled", "🔄")
        CreateToggle(holder, "防强制凝视(拦截focusCamera)", "AntiFocusCamera_Enabled", "🎥")
        CreateToggle(holder, "防被凝视(拦截stalkPlayer)", "AntiStalkPlayer_Enabled", "👁️")
        CreateToggle(holder, "防强制传送(拦截charPivotTo)", "AntiCharPivotTo_Enabled", "📍")
        CreateToggle(holder, "防检查点传送(拦截charCheckpoint)", "AntiCharCheckpoint_Enabled", "🏁")
        CreateToggle(holder, "防被踢下座位(拦截getRidOfSitting)", "AntiGetRidOfSitting_Enabled", "💺")
        CreateToggle(holder, "防强制空闲动画", "AntiFreezeIdle_Enabled", "❄️")
        CreateToggle(holder, "防强制表情(拦截playEmote)", "AntiPlayEmote_Enabled", "🎬")
        CreateToggle(holder, "防强制Ragdoll(增强版)", "AntiRagdollEnhanced_Enabled", "🤸")
        CreateToggle(holder, "防被弹下车(拦截eject)", "AntiEjectEnhanced_Enabled", "🚪")
        CreateToggle(holder, "防车辆被拖(拦截towing)", "AntiTow_Enabled", "🚛")
        CreateToggle(holder, "防车辆被偷(拦截stealVehicle)", "AntiVehicleTheft_Enabled", "🔑")
        --- separator ---
        -- [v10.63新增] Hook 类防护
        CreateToggle(holder, "防客户端踢出(Hook Kick)", "AntiClientKick_Enabled", "🛑")
    end)
end)

CreateSideIcon("🏃", function()
    OpenPopup("🏃 移动", function(holder)
        CreateSlider(holder, "移动速度", 16, 200, Config.Speed_Value, "Speed_Value", false)
        CreateToggle(holder, "速度增强", "Speed_Enabled", "🏃")
        CreateSlider(holder, "跳跃力", 50, 500, Config.JumpPower_Value, "JumpPower_Value", false)
        CreateToggle(holder, "跳跃增强", "JumpPower_Enabled", "🦘")
        CreateSlider(holder, "飞行速度", 10, 200, Config.Fly_Speed, "Fly_Speed", false)
        CreateToggle(holder, "飞行", "Fly_Enabled", "✈️")
        CreateToggle(holder, "SAC绕过飞行", "SACFly_Enabled", "🦅")
        CreateToggle(holder, "穿墙", "Noclip_Enabled", "👻")
        CreateToggle(holder, "无限跳跃", "InfiniteJump_Enabled", "⬆️")
        CreateToggle(holder, "无跳跃限制", "NoJumpLimit_Enabled", "🔓")
        CreateToggle(holder, "点击传送", "ClickTeleport_Enabled", "🖱️")
        CreateSlider(holder, "客户端移速", 16, 200, Config.ClientWalkSpeed_Value, "ClientWalkSpeed_Value", false)
        CreateToggle(holder, "客户端移速", "ClientWalkSpeed_Enabled", "🏃")
        CreateSlider(holder, "游泳速度值", 16, 200, Config.ClientSwimSpeed_Value, "ClientSwimSpeed_Value", false)
        CreateToggle(holder, "客户端游泳速度", "ClientSwimSpeed_Enabled", "🏊")
    end)
end)

CreateSideIcon("👁️", function()
    OpenPopup("👁️ 视觉", function(holder)
        -- 透视
        CreateToggle(holder, "玩家透视", "ESP_Enabled", "👻")
        CreateToggle(holder, "近战攻击线", "DrawMeleeLine_Enabled", "📏")
        CreateToggle(holder, "远程攻击线", "DrawRangedLine_Enabled", "📐")
        --- separator ---
        -- FOV
        CreateSlider(holder, "FOV值", 60, 180, Config.FOVModify_Value, "FOVModify_Value", false)
        CreateToggle(holder, "FOV修改", "FOVModify_Enabled", "👁️")
        CreateSlider(holder, "相机FOV", 60, 180, Config.CameraFOV_Value, "CameraFOV_Value", false)
        CreateToggle(holder, "相机FOV", "CameraFOV_Enabled", "🎥")
        --- separator ---
        -- 光照
        CreateToggle(holder, "全亮模式", "Fullbright_Enabled", "☀️")
        CreateToggle(holder, "防致盲", "AntiBlind_Enabled", "🕶️")
        CreateToggle(holder, "防模糊", "AntiBlur_Enabled", "🌫️")
        CreateToggle(holder, "防色彩校正", "AntiColorCorrection_Enabled", "🎨")
        CreateToggle(holder, "强制白天", "ForceDay_Enabled", "☀️")
        CreateToggle(holder, "强制夜晚", "ForceNight_Enabled", "🌙")
        CreateToggle(holder, "无雾", "NoFog_Enabled", "🌬️")
        CreateSlider(holder, "亮度值", 1, 10, Config.Brightness_Value, "Brightness_Value", false)
        CreateToggle(holder, "亮度增强", "Brightness_Enabled", "💡")
        --- separator ---
        -- 环境
        CreateToggle(holder, "天气控制", "WeatherControl_Enabled", "🌦️")
        CreateSlider(holder, "时间(0-24)", 0, 24, Config.TimeControl_Hour, "TimeControl_Hour", false)
        CreateToggle(holder, "时间控制", "TimeControl_Enabled", "🕐")
        CreateToggle(holder, "持续清理视觉效果", "CleanLightingEffects_Enabled", "✨")
        --- separator ---
        -- [v10.56新增] 视觉扩展
        CreateToggle(holder, "禁用太阳光晕", "NoSunRays_Enabled", "☀️")
    end)
end)

CreateSideIcon("🔧", function()
    OpenPopup("🔧 实用", function(holder)
        -- 互动
        CreateToggle(holder, "秒互动", "InstantInteract_Enabled", "⚡")
        CreateToggle(holder, "全图超距互动", "GlobalInteract_Enabled", "🌐")
        CreateToggle(holder, "工具无限耐久", "Tool_InfiniteDurability", "♾️")
        CreateToggle(holder, "自动重生", "AutoRespawn_Enabled", "💀")
        --- separator ---
        -- 车辆
        CreateToggle(holder, "自动翻车复位", "UnflipVehicle_Enabled", "🔄")
        --- separator ---
        -- [v10.62新增] 车辆速度
        CreateSlider(holder, "车辆最大速度(mph)", 100, 1000, Config.VehicleSpeedHack_Value, "VehicleSpeedHack_Value", false)
        CreateToggle(holder, "车辆速度修改", "VehicleSpeedHack_Enabled", "🚀")
        --- separator ---
        -- [v10.61新增] 车辆功能扩展
        CreateToggle(holder, "车锁刷(锁/解锁附近车)", "VehicleLockSpam_Enabled", "🔐")
        CreateToggle(holder, "车辆清洁刷", "VehicleCleanSpam_Enabled", "🧼")
        CreateToggle(holder, "大灯闪烁刷", "HeadlightSpam_Enabled", "💡")
        CreateToggle(holder, "警笛刷", "SirenSpam_Enabled", "🚨")
        CreateToggle(holder, "喇叭刷(转向灯)", "HornSpam_Enabled", "📯")
        CreateToggle(holder, "防车盗窃", "VehicleAntiSteal_Enabled", "🛡️")
        CreateToggle(holder, "车辆锁定保护", "VehicleLockProtect_Enabled", "🔒")
        --- separator ---
        --- separator ---
        -- [v10.56新增] 实用扩展
        CreateToggle(holder, "快速复活", "FastRespawn_Enabled", "⚡")
        --- separator ---
        -- [v10.57新增] 服务器端实用功能
        CreateToggle(holder, "免费特殊工具", "FreeTools_Enabled", "🎒")
        CreateToggle(holder, "自动钓鱼刷钱", "CatchFishSpam_Enabled", "🎣")
        CreateToggle(holder, "自动医疗包", "FreeHealSpam_Enabled", "➕")
        CreateToggle(holder, "服务器点击传送(Ctrl+Q)", "ServerClickTeleport_Enabled", "✨")
        CreateToggle(holder, "凝视最近玩家(F6)", "StalkNearestPlayer_Enabled", "👁️")
        --- separator ---
        -- [v10.60新增] 刷钱功能 [v10.62修正] paycheck 不可注入，改为真实途径
        CreateToggle(holder, "刷钱-钓鱼(catchFish)", "MoneySpam_catchFish", "🐟")
        CreateToggle(holder, "刷钱-捡地面现金", "MoneySpam_cashDropPickup", "💵")
        CreateToggle(holder, "刷钱-本地视觉显示", "MoneySpam_localVisualOnly", "💰")
        CreateToggle(holder, "刷钱-任务奖励(talkToMission)", "MoneySpam_talkToMission", "📜")
        CreateToggle(holder, "刷钱-任务完成(questCompleted)", "MoneySpam_questCompleted", "📋")
        CreateToggle(holder, "刷钱-自动复活(revive)", "MoneySpam_revive", "🔄")
        --- separator ---
        -- [v10.63新增] 暴力功能 - 群体攻击
        CreateSlider(holder, "群体铐住范围", 10, 500, Config.MassHandcuff_Range, "MassHandcuff_Range", false)
        CreateToggle(holder, "群体铐住(MassHandcuff)", "MassHandcuff_Enabled", "🔒")
        CreateSlider(holder, "群体逮捕范围", 10, 500, Config.MassArrest_Range, "MassArrest_Range", false)
        CreateToggle(holder, "群体逮捕(MassArrest)", "MassArrest_Enabled", "🚔")
        CreateSlider(holder, "群体倒地范围", 10, 1000, Config.MassRagdoll_Range, "MassRagdoll_Range", false)
        CreateToggle(holder, "群体倒地(MassRagdoll)", "MassRagdoll_Enabled", "🤸")
        CreateSlider(holder, "群体弹下范围", 10, 1000, Config.MassEject_Range, "MassEject_Range", false)
        CreateToggle(holder, "群体弹下车(MassEject)", "MassEject_Enabled", "🚪")
        CreateSlider(holder, "群体眩晕范围", 10, 1000, Config.MassStun_Range, "MassStun_Range", false)
        CreateToggle(holder, "群体眩晕(三连击)", "MassStun_Enabled", "💫")
        --- separator ---
        -- [v10.63新增] 暴力功能 - 车辆攻击
        CreateSlider(holder, "摧毁车辆范围", 50, 1000, Config.VehicleDestroySpam_Range, "VehicleDestroySpam_Range", false)
        CreateToggle(holder, "摧毁附近车辆(damage:100)", "VehicleDestroySpam_Enabled", "💥")
        CreateSlider(holder, "强制停车范围", 50, 1000, Config.VehicleStopAll_Range, "VehicleStopAll_Range", false)
        CreateToggle(holder, "强制附近车辆停车", "VehicleStopAll_Enabled", "🛑")
        CreateSlider(holder, "强制锁车范围", 50, 1000, Config.VehicleLockAll_Range, "VehicleLockAll_Range", false)
        CreateToggle(holder, "强制锁附近车辆", "VehicleLockAll_Enabled", "🔐")
        --- separator ---
        -- [v10.63新增] 极端暴力功能
        CreateSlider(holder, "弹幕风暴范围", 50, 2000, Config.BulletStorm_Range, "BulletStorm_Range", false)
        CreateToggle(holder, "弹幕风暴(50发/帧)", "BulletStorm_Enabled", "🌪️")
        CreateSlider(holder, "击飞范围", 10, 500, Config.ForceFling_Range, "ForceFling_Range", false)
        CreateToggle(holder, "强制击飞附近玩家", "ForceFling_Enabled", "🌀")
    end)
end)

CreateSideIcon("🎯", function()
    OpenPopup("🎯 调试", function(holder)
        -- 调试
        CreateToggle(holder, "屏幕日志", "ScreenLog_Enabled", "📋")
        CreateToggle(holder, "Debug模式", "DebugMode_Enabled", "🐛")
    end)
end)
-- ==========================================
-- [核心视觉清理系统 - 深度扫描版]
-- ==========================================
function ClearLockVisuals(lockName)
    local mode = lockName == "KillSystem_MeleeLock" and "Melee" or "Ranged"
    local registry = State.VisualRegistry[mode]

    for char, hl in pairs(registry) do
        if hl then pcall(function() hl:Destroy() end) end
    end
    State.VisualRegistry[mode] = {}

    local function deepClean(parent)
        if not parent then return end
        for _, obj in ipairs(parent:GetDescendants()) do
            if obj:IsA("Highlight") and obj.Name == lockName then
                pcall(function() obj:Destroy() end)
            end
        end
    end
    pcall(deepClean, workspace)
    pcall(deepClean, Players)
    -- 新增：扫描所有玩家的角色（防止角色在PlayerGui或其他位置）
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            pcall(deepClean, player.Character)
        end
    end
end

local function SyncLockVisuals(activeChars, mode, lockName, color)
    -- 安全状态锁1：如果对应功能已被关闭，强行中断并清理
    if not Config[mode .. "_Enabled"] then
        ClearLockVisuals(lockName)
        return
    end

    local registry = State.VisualRegistry[mode]
    local activeMap = {}

    for _, char in ipairs(activeChars) do
        if char and char.Parent then
            activeMap[char] = true
            if not registry[char] then
                -- 安全状态锁2：防止多线程并发在关闭瞬间强行创建
                if not Config[mode .. "_Enabled"] then
                    ClearLockVisuals(lockName)
                    return
                end
                local newHl = Instance.new("Highlight")
                newHl.Name = lockName
                newHl.FillColor = color
                newHl.OutlineColor = Color3.fromRGB(255, 255, 255)
                newHl.FillTransparency = 0.5
                newHl.Parent = char
                registry[char] = newHl
            end
        end
    end

    for char, hl in pairs(registry) do
        if not activeMap[char] or not char.Parent or not hl.Parent then
            if hl and hl.Parent then hl:Destroy() end
            registry[char] = nil
        end
    end
end

-- ==========================================
-- [核心公共逻辑：NPC与轮胎缓存扫描]
-- ==========================================
local npcCache = {}
local lastNpcScanTime = 0
local tireCache = {}
local lastTireScanTime = 0

local function UpdateNPCCache()
    if tick() - lastNpcScanTime < 0.5 then return end
    lastNpcScanTime = tick()
    table.clear(npcCache)
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("Model") and not Players:GetPlayerFromCharacter(desc) then
            local hum = desc:FindFirstChildOfClass("Humanoid")
            local root = desc:FindFirstChild("HumanoidRootPart")
            if hum and root then
                table.insert(npcCache, {Char = desc, Humanoid = hum, Root = root})
            end
        end
    end
end

local function UpdateTireCache()
    if tick() - lastTireScanTime < 1 then return end
    lastTireScanTime = tick()
    table.clear(tireCache)
    local vehicles = workspace:FindFirstChild("Gameplay") and workspace.Gameplay:FindFirstChild("Vehicles")
    if vehicles then
        for _, car in ipairs(vehicles:GetChildren()) do
            for _, desc in ipairs(car:GetDescendants()) do
                if desc.Name == "WheelCollision" and not desc:GetAttribute("DontPuncture") then
                    table.insert(tireCache, desc)
                end
            end
        end
    end
end

local function GetValidTargets(mode)
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") or not localChar:FindFirstChild("Humanoid") then return {} end
    if localChar.Humanoid.Health <= 0 then return {} end

    local localRoot = localChar.HumanoidRootPart
    local validTargets = {}

    local checkFriends = Config[mode .. "_CheckFriends"]
    local checkVis = Config[mode .. "_CheckVisibility"]
    if mode == "Ranged" and Config.Ranged_WallBang then checkVis = false end
    local allowedTeams = Config[mode .. "_AllowedTeams"]
    local range = Config[mode .. "_Range"]
    local targetNPC = Config[mode .. "_TargetNPC"]

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if #allowedTeams > 0 and (not player.Team or not table.find(allowedTeams, player.Team.Name)) then continue end
            if checkFriends and LocalPlayer:IsFriendsWith(player.UserId) then continue end

            local targetChar = player.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 then
                local targetRoot = targetChar.HumanoidRootPart
                local dist = (targetRoot.Position - localRoot.Position).Magnitude
                if dist <= range then
                    local isVisible = true
                    if checkVis then
                        local params = RaycastParams.new()
                        params.FilterDescendantsInstances = {localChar}
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        local hit = workspace:Raycast(localRoot.Position, (targetRoot.Position - localRoot.Position), params)
                        if hit and not hit.Instance:IsDescendantOf(targetChar) then isVisible = false end
                    end
                    if isVisible then
                        table.insert(validTargets, {Player = player, Dist = dist, Char = targetChar, Root = targetRoot, IsNPC = false})
                    end
                end
            end
        end
    end

    if targetNPC then
        UpdateNPCCache()
        for _, npcData in ipairs(npcCache) do
            if npcData.Char ~= localChar and npcData.Humanoid.Health > 0 then
                local dist = (npcData.Root.Position - localRoot.Position).Magnitude
                if dist <= range then
                    local isVisible = true
                    if checkVis then
                        local params = RaycastParams.new()
                        params.FilterDescendantsInstances = {localChar}
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        local hit = workspace:Raycast(localRoot.Position, (npcData.Root.Position - localRoot.Position), params)
                        if hit and not hit.Instance:IsDescendantOf(npcData.Char) then isVisible = false end
                    end
                    if isVisible then
                        table.insert(validTargets, {Player = {Name = npcData.Char.Name, UserId = 0}, Dist = dist, Char = npcData.Char, Root = npcData.Root, IsNPC = true})
                    end
                end
            end
        end
    end

    table.sort(validTargets, function(a, b) return a.Dist < b.Dist end)
    return validTargets
end

local function GetValidTires(rangeVal)
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return {} end
    local localRoot = localChar.HumanoidRootPart
    local range = rangeVal
    local validTires = {}

    UpdateTireCache()
    for _, tire in ipairs(tireCache) do
        if tire.Parent and tire:GetAttribute("Durability") ~= 0 then
            local dist = (tire.Position - localRoot.Position).Magnitude
            if dist <= range then
                table.insert(validTires, {Tire = tire, Dist = dist, Pos = tire.Position})
            end
        end
    end
    table.sort(validTires, function(a, b) return a.Dist < b.Dist end)
    return validTires
end

-- ==========================================
-- [近战战斗逻辑]
-- ==========================================
local function GetBodyPartsArray(character)
    local parts = {}
    local priority = {"Head", "Torso", "UpperTorso", "HumanoidRootPart", "LowerTorso", "LeftArm", "RightArm", "LeftHand", "RightHand", "LeftLeg", "RightLeg"}
    for _, name in ipairs(priority) do
        local p = character:FindFirstChild(name)
        if p then table.insert(parts, { [1] = name, [2] = 1 }) end
    end
    if #parts == 0 then table.insert(parts, { [1] = "HumanoidRootPart", [2] = 1 }) end
    return parts
end

function StartMeleeLoop()
    for _, t in ipairs(State.MeleeThreads) do pcall(task.cancel, t) end
    State.MeleeThreads = {}

    local threadCount = Config.Melee_HyperThread and 3 or 1

    for i = 1, threadCount do
        local t = task.spawn(function()
            while Config.Melee_Enabled do
                task.wait(Config.Melee_Delay > 0 and Config.Melee_Delay or 0.016)

                -- [v10.58d] 战斗模式：恢复 FireServer 替代 SetAttribute
                if Config.Melee_ForceCombatMode and tick() - State.CombatModeTick > (0.4 + math.random()*0.2) then
                    State.CombatModeTick = tick()
                    local r = FetchRemote()
                    if r then pcall(function() r:FireServer("combatMode", true) end) end
                elseif Config.Melee_SelfAntiCombatMode and not Config.Melee_ForceCombatMode and tick() - State.CombatModeTick > 0.5 then
                    State.CombatModeTick = tick()
                    local r = FetchRemote()
                    if r then pcall(function() r:FireServer("combatMode", false) end) end
                end

                local targets = GetValidTargets('Melee')
                local localChar = LocalPlayer.Character
                local activeChars = {}

                if #targets > 0 and localChar and localChar:FindFirstChild('HumanoidRootPart') then
                    local localRoot = localChar.HumanoidRootPart
                    local localPos = localRoot.Position

                    for _, targetData in ipairs(targets) do
                        local targetChar = targetData.Char
                        table.insert(activeChars, targetChar)

                        task.spawn(function()
                            -- [v10.61修复] BrutalDamage 改为 FireServer 真正发包
                            -- v10.53 改为"直接修改目标Humanoid.Health"，但客户端对其他玩家Humanoid
                            -- 没有网络所有权，所以无效。用户反馈"暴力伤害完全是虚的"
                            local targetHum = targetChar:FindFirstChild('Humanoid')
                            local targetRoot = targetChar:FindFirstChild('HumanoidRootPart')
                            if targetHum and targetHum.Health > 0 and targetRoot then
                                local targetPos = targetRoot.Position
                                local shotCode = { localPos, (targetPos - localPos).Unit }

                                -- 移除目标的 BulletProof / SpawnProtection 让伤害生效
                                pcall(function() targetChar:SetAttribute('BulletProof', nil) end)
                                pcall(function() targetChar:SetAttribute('SpawnProtection', nil) end)

                                -- 基础伤害
                                local damageAmount = 30
                                local hitCount = Config.Melee_MultiHit and #GetBodyPartsArray(targetChar) or 1

                                -- BrutalDamage 模式：使用 FireServer 真正发包
                                if Config.BrutalDamage_Enabled then
                                    local damageFactor = Config.BrutalDamage_Factor
                                    if Config.MaxDamageFactor_Enabled then damageFactor = 999 end
                                    local allBodyParts = Config.AllBodyParts_Enabled and {
                                        { "Head", 1 }, { "Torso", 2 },
                                        { "LeftArm", 1 }, { "RightArm", 1 },
                                        { "LeftLeg", 1 }, { "RightLeg", 1 }
                                    } or { { "Head", 1 } }

                                    -- 多重伤害发送
                                    local remote = FetchRemote()
                                    if remote then
                                        for i = 1, Config.BrutalDamage_MultiCount do
                                            task.spawn(function()
                                                pcall(function()
                                                    remote:FireServer("damage", {
                                                        ["bodyParts"] = allBodyParts,
                                                        ["shotCode"] = shotCode,
                                                        ["pos"] = targetPos,
                                                        ["target"] = targetData.Player,
                                                        ["damageFactor"] = damageFactor,
                                                        ["bulletProofTool"] = false
                                                    })
                                                end)
                                            end)
                                        end
                                    end
                                else
                                    -- 普通模式：单次伤害发包
                                    local remote = FetchRemote()
                                    if remote then
                                        pcall(function()
                                            remote:FireServer("damage", {
                                                ["bodyParts"] = { { "HumanoidRootPart", 1 } },
                                                ["shotCode"] = shotCode,
                                                ["pos"] = targetPos,
                                                ["target"] = targetData.Player,
                                                ["damageFactor"] = 1.0
                                            })
                                        end)
                                    end
                                end
                            end
                            if Config.BypassBulletProof_Enabled then
                                pcall(function() targetChar:SetAttribute('BulletProof', nil) end)
                            end
                            if Config.DrawMeleeLine_Enabled then
                                local targetPos = targetData.Root.Position
                                pcall(function() DrawAttackLine(localPos, targetPos, Color3.fromRGB(255, 50, 50), 0.15) end)
                            end
                        end)
                    end
                end

                -- [v10.53] AutoPopTires：直接修改轮胎属性
                if Config.Melee_AutoPopTires then
                    local tires = GetValidTires(Config.Melee_Range)
                    for _, tireData in ipairs(tires) do
                        task.spawn(function()
                            pcall(function() tireData.Tire:SetAttribute('Durability', 0) end)
                        end)
                    end
                end

                if i == 1 then
                    SyncLockVisuals(activeChars, 'Melee', 'KillSystem_MeleeLock', Color3.fromRGB(255, 0, 0))
                end
            end
        end)
        table.insert(State.MeleeThreads, t)
    end
end

-- ==========================================
-- [远程战斗逻辑]
-- ==========================================
-- 修复：GetEquippedWeaponName 增加多种武器获取方式
-- 修复：GetBarrelPos 使用 WorldPosition 正确获取枪口位置
-- 新增：调试日志便于排查远程杀戮无效问题

local function GetEquippedWeaponName()
    local char = LocalPlayer.Character
    if not char then return "Unarmed" end
    -- 方法1：直接获取Tool的Name
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then return item.Name end
    end
    -- 方法2：获取有Handle的Model的Name
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("Handle") then return item.Name end
    end
    -- 方法3：检查Config模块中的武器名
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") or (item:IsA("Model") and item:FindFirstChild("Handle")) then
            local cfg = item:FindFirstChild("Config")
            if cfg then
                local success, cfgData = pcall(require, cfg)
            if success and cfgData and cfgData.NAME then
                    return cfgData.NAME
                end
            end
        end
    end
    return "Unarmed"
end

local function GetBarrelPos(char)
    -- 方法1：从Tool中查找Barrel（使用WorldPosition）
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local barrel = item:FindFirstChild("Barrel")
            if barrel then
                -- 优先使用WorldPosition（正确的世界坐标）
                if barrel:IsA("BasePart") then
                    return barrel.Position
                elseif barrel:IsA("Attachment") then
                    return barrel.WorldPosition
                end
            end
            local handle = item:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                return handle.Position
            end
        end
    end
    -- 方法2：从Model中查找Barrel
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("Handle") then
            local barrel = item:FindFirstChild("Barrel")
            if barrel then
                if barrel:IsA("BasePart") then
                    return barrel.Position
                elseif barrel:IsA("Attachment") then
                    return barrel.WorldPosition
                end
            end
            local handle = item:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                return handle.Position
            end
        end
    end
    -- 方法3：使用HumanoidRootPart位置
    if char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart.Position
    end
    return Vector3.new(0, 0, 0)
end

-- 新增：获取正确的发射位置（摄像机射线起点）
-- 根据反编译分析：游戏laserShoot使用ScreenPointToRay从屏幕中心发射射线
-- shotCode[1]应为射线Origin（摄像机位置），而非枪口Barrel位置
local function GetShootOrigin()
    local camera = workspace.CurrentCamera
    if not camera then
        -- 备选：使用玩家位置
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            return char.HumanoidRootPart.Position
        end
        return Vector3.new(0, 0, 0)
    end
    -- 使用ScreenPointToRay获取屏幕中心射线
    local viewportSize = camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local ray = camera:ScreenPointToRay(screenCenter.X, screenCenter.Y)
    -- 返回射线起点（摄像机位置）
    return ray.Origin
end

function StartRangedLoop()
    for _, t in ipairs(State.RangedThreads) do pcall(task.cancel, t) end
    State.RangedThreads = {}

    local threadCount = Config.Ranged_HyperThread and 3 or 1

    for i = 1, threadCount do
        local t = task.spawn(function()
            while Config.Ranged_Enabled do
                task.wait(Config.Ranged_Delay > 0 and Config.Ranged_Delay or 0.016)

                local targets = GetValidTargets('Ranged')
                local localChar = LocalPlayer.Character
                local activeChars = {}

                -- [v10.53] AutoPopTires
                if Config.Ranged_AutoPopTires then
                    local tires = GetValidTires(Config.Ranged_Range)
                    for _, tireData in ipairs(tires) do
                        task.spawn(function()
                            pcall(function() tireData.Tire:SetAttribute('Durability', 0) end)
                        end)
                    end
                end

                if #targets > 0 and localChar and localChar:FindFirstChild('HumanoidRootPart') then
                    for _, targetData in ipairs(targets) do
                        local targetChar = targetData.Char
                        table.insert(activeChars, targetChar)

                        task.spawn(function()
                            -- [v10.61修复] Ranged 改为 FireServer 真正发包
                            local targetHum = targetChar:FindFirstChild('Humanoid')
                            local targetRoot = targetChar:FindFirstChild('HumanoidRootPart')
                            if targetHum and targetHum.Health > 0 and targetRoot then
                                local targetPos = targetRoot.Position
                                local shootOrigin = GetShootOrigin()
                                local shotCode = { shootOrigin, (targetPos - shootOrigin).Unit }
                                local weaponName = GetEquippedWeaponName()

                                -- 移除目标的 BulletProof / SpawnProtection
                                pcall(function() targetChar:SetAttribute('BulletProof', nil) end)
                                pcall(function() targetChar:SetAttribute('SpawnProtection', nil) end)

                                local remote = FetchRemote()
                                if remote then
                                    -- BrutalDamage 模式
                                    local damageFactor = 1.0
                                    local bulletCount = Config.Ranged_MultiBullet and 3 or 1
                                    local allBodyParts = { { "HumanoidRootPart", 1 } }
                                    local hitPartName = Config.Ranged_AutoHeadshot and "Head" or "HumanoidRootPart"

                                    if Config.Ranged_AutoHeadshot then
                                        damageFactor = 1.5
                                        allBodyParts = { { "Head", 1 } }
                                    end
                                    if Config.BrutalDamage_Enabled then
                                        damageFactor = Config.BrutalDamage_Factor
                                        if Config.MaxDamageFactor_Enabled then damageFactor = 999 end
                                        bulletCount = Config.BrutalDamage_MultiCount
                                        if Config.AllBodyParts_Enabled then
                                            allBodyParts = {
                                                { "Head", 1 }, { "Torso", 2 },
                                                { "LeftArm", 1 }, { "RightArm", 1 },
                                                { "LeftLeg", 1 }, { "RightLeg", 1 }
                                            }
                                        end
                                    end

                                    -- 发送 bullet 事件（视觉）
                                    for i = 1, bulletCount do
                                        pcall(function()
                                            remote:FireServer("bullet", {
                                                weaponName = weaponName,
                                                posDestroyX = targetPos.X + (i * 0.5),
                                                pos = targetPos
                                            })
                                        end)
                                    end

                                    -- 发送 damage 事件（实际伤害）
                                    for i = 1, bulletCount do
                                        task.spawn(function()
                                            pcall(function()
                                                remote:FireServer("damage", {
                                                    ["bodyParts"] = allBodyParts,
                                                    ["shotCode"] = shotCode,
                                                    ["pos"] = targetPos,
                                                    ["target"] = targetData.Player,
                                                    ["damageFactor"] = damageFactor,
                                                    ["bulletProofTool"] = false
                                                })
                                            end)
                                        end)
                                    end
                                end
                            end
                            if Config.BypassBulletProof_Enabled then
                                pcall(function() targetChar:SetAttribute('BulletProof', nil) end)
                            end
                            if Config.DrawRangedLine_Enabled then
                                local shootOrigin = GetShootOrigin()
                                local hitPartName = Config.Ranged_AutoHeadshot and 'Head' or 'HumanoidRootPart'
                                local hitPart = targetChar:FindFirstChild(hitPartName) or targetChar:FindFirstChild('HumanoidRootPart')
                                if hitPart then
                                    pcall(function() DrawAttackLine(shootOrigin, hitPart.Position, Color3.fromRGB(50, 150, 255), 0.2) end)
                                end
                            end
                        end)
                    end
                end

                if i == 1 then
                    SyncLockVisuals(activeChars, 'Ranged', 'KillSystem_RangedLock', Color3.fromRGB(0, 0, 255))
                end
            end
        end)
        table.insert(State.RangedThreads, t)
    end
end

-- ==========================================
-- [ESP与实用工具逻辑 - 兼容workspace.Characters]
-- ==========================================
function ClearESP()
    for char, obj in pairs(State.ESPObjects) do
        if obj.Highlight then obj.Highlight:Destroy() end
        if obj.Billboard then obj.Billboard:Destroy() end
    end
    State.ESPObjects = {}
end

local function UpdateESP()
    if not Config.ESP_Enabled then return end

    local drawnChars = {}
    local localChar = LocalPlayer.Character

    local function ApplyESP(char, name, teamColor)
        if char == localChar then return end
        if not char or not char.Parent then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then return end

        drawnChars[char] = true
        local obj = State.ESPObjects[char]

        local needRebuild = false
        if not obj then
            needRebuild = true
        else
            if not obj.Highlight or not obj.Highlight.Parent or obj.Highlight.Parent ~= char then needRebuild = true end
            if not obj.Billboard or not obj.Billboard.Parent or obj.Billboard.Parent ~= root then needRebuild = true end
        end

        if needRebuild then
            if obj then
                if obj.Highlight then pcall(function() obj.Highlight:Destroy() end) end
                if obj.Billboard then pcall(function() obj.Billboard:Destroy() end) end
            end
            obj = {}
            obj.Highlight = Instance.new("Highlight")
            obj.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            obj.Highlight.FillTransparency = 0.7
            obj.Highlight.Parent = char

            obj.Billboard = Instance.new("BillboardGui")
            obj.Billboard.Size = UDim2.new(0, 200, 0, 30)
            obj.Billboard.StudsOffset = Vector3.new(0, 3, 0)
            obj.Billboard.AlwaysOnTop = true
            obj.Billboard.Parent = root

            local lbl = Instance.new("TextLabel", obj.Billboard)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.TextStrokeTransparency = 0
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            obj.Label = lbl

            State.ESPObjects[char] = obj
        end

        obj.Highlight.FillColor = teamColor or Color3.fromRGB(255, 255, 255)

        local isMeleeLocked = State.VisualRegistry.Melee[char] ~= nil
        local isRangedLocked = State.VisualRegistry.Ranged[char] ~= nil

        local lockText, textColor = "", teamColor or Color3.fromRGB(255, 255, 255)
        if isMeleeLocked then
            lockText = " [近战锁]"
            textColor = Color3.fromRGB(255, 50, 50)
            obj.Highlight.FillColor = Color3.fromRGB(255, 50, 50)
        elseif isRangedLocked then
            lockText = " [远程锁]"
            textColor = Color3.fromRGB(50, 150, 255)
            obj.Highlight.FillColor = Color3.fromRGB(50, 150, 255)
        end

        obj.Label.TextColor3 = textColor
        obj.Label.Text = string.format("%s [%d/%d]%s", name, math.floor(hum.Health), hum.MaxHealth, lockText)
    end

    -- 1. 扫描 Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local tColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
            if char then ApplyESP(char, player.Name, tColor) end
        end
    end

    -- 2. 扫描 workspace.Characters (该游戏特有机制)
    local wsChars = workspace:FindFirstChild("Characters")
    if wsChars then
        for _, char in ipairs(wsChars:GetChildren()) do
            if char:IsA("Model") and char ~= localChar then
                local player = Players:FindFirstChild(char.Name)
                local tColor = player and player.Team and player.Team.TeamColor.Color or Color3.fromRGB(200, 200, 200)
                ApplyESP(char, char.Name, tColor)
            end
        end
    end

    -- 3. 清理不再需要绘制的 ESP
    for char, obj in pairs(State.ESPObjects) do
        if not drawnChars[char] or not char.Parent then
            if obj.Highlight then obj.Highlight:Destroy() end
            if obj.Billboard then obj.Billboard:Destroy() end
            State.ESPObjects[char] = nil
        end
    end
end

-- 互动系统（已移除自动拾取，仅保留秒互动与全图互动）
local function ProcessPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end

    if not prompt:GetAttribute("KS_OrigMaxDist") then
        prompt:SetAttribute("KS_OrigMaxDist", prompt.MaxActivationDistance)
    end
    if not prompt:GetAttribute("KS_OrigHoldDur") then
        prompt:SetAttribute("KS_OrigHoldDur", prompt.HoldDuration)
    end

    if Config.GlobalInteract_Enabled then
        prompt.MaxActivationDistance = 9999
    else
        prompt.MaxActivationDistance = prompt:GetAttribute("KS_OrigMaxDist")
    end

    if Config.InstantInteract_Enabled then
        prompt.HoldDuration = 0
    else
        prompt.HoldDuration = prompt:GetAttribute("KS_OrigHoldDur")
    end
end

local function ScanAndProcessPrompts()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            ProcessPrompt(obj)
        end
    end
end

workspace.DescendantAdded:Connect(function(d)
    if d:IsA("ProximityPrompt") then
        ProcessPrompt(d)
    end
end)

task.spawn(function()
    while true do
        if Config.InstantInteract_Enabled or Config.GlobalInteract_Enabled then
            pcall(ScanAndProcessPrompts)
            task.wait(1)
        else
            task.wait(2)
        end
    end
end)

-- [防御系统 - v10.53纯客户端版]
-- 已移除OnClientEvent Hook，所有防御功能通过帧循环实现
-- ==========================================

-- v10.53: 所有防御功能通过帧循环实现，无需OnClientEvent Hook

-- 快速起身循环：持续监控Humanoid状态，物理Ragdoll时立即起身
-- 与AntiRagdoll互补：AntiRagdoll只拦截服务器ragdoll事件，
-- FastGetUp能捕获所有进入Physics状态的Ragdoll（包括物理碰撞导致）
task.spawn(function()
    while true do
        if Config.FastGetUp_Enabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                local state = hum:GetState()
                -- Physics状态通常表示Ragdoll（包括被车撞、爆炸等物理触发）
                if state == Enum.HumanoidStateType.Physics then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
            task.wait(0.1)
        else
            task.wait(1)
        end
    end
end)

-- 持续清理视觉效果：移除游戏添加的非系统Lighting效果
-- 保留我们自己的BlurEffect（名为KillSystem_Blur）
-- 如果NoKilledVisual开启，则KilledColorCorrection由其管理
local CleanEffectsLastCheck = 0
task.spawn(function()
    while true do
        if Config.CleanLightingEffects_Enabled then
            -- 限频检查，避免每帧遍历
            if tick() - CleanEffectsLastCheck >= 1 then
                CleanEffectsLastCheck = tick()
                for _, child in ipairs(game.Lighting:GetChildren()) do
                    -- 跳过我们自己的BlurEffect
                    if child.Name == "KillSystem_Blur" then continue end
                    -- 如果NoKilledVisual开启，跳过KilledColorCorrection（由其管理）
                    if child.Name == "KilledColorCorrection" and Config.NoKilledVisual_Enabled then continue end
                    -- 禁用各种视觉效果
                    if child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") or
                       child:IsA("DepthOfFieldEffect") or child:IsA("SunRaysEffect") or
                       child:IsA("BlurEffect") or child:IsA("Atmosphere") then
                        pcall(function() child.Enabled = false end)
                    end
                end
            end
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

print('[KillSystem v10.53] 防御系统纯客户端版已加载。')

-- [v10.45修复] 移除重复的防御系统Heartbeat连接（防御系统v2）
-- 此Heartbeat:Connect与统一Heartbeat处理器（约4808行）功能完全重复
-- 统一处理器已包含：AntiRagdoll、FastGetUp、NoKilledVisual、AntiCharHidden
-- 保留两个Heartbeat连接会浪费性能并可能导致冲突
-- 保留GuiService引用供统一Heartbeat使用
local GuiService = game:GetService("GuiService")

-- [v10.53] 反弹出：客户端监控循环
local WasInVehicle = false
task.spawn(function()
    while true do
        if Config.AntiEject_Enabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild('Humanoid')
                local isCurrentlyInVehicle = hum and hum.Sit or false
                if WasInVehicle and not isCurrentlyInVehicle then
                    task.spawn(function()
                        task.wait(5)
                        if not char or not char:FindFirstChild('HumanoidRootPart') then return end
                        local localPos = char.HumanoidRootPart.Position
                        local nearestVehicle = nil
                        local nearestDist = math.huge
                        local vehicles = workspace:FindFirstChild('Gameplay') and workspace.Gameplay:FindFirstChild('Vehicles')
                        if vehicles then
                            for _, car in ipairs(vehicles:GetChildren()) do
                                if car:IsA('Model') then
                                    local primaryPart = car.PrimaryPart or car:FindFirstChildWhichIsA('BasePart')
                                    if primaryPart then
                                        local dist = (primaryPart.Position - localPos).Magnitude
                                        if dist < nearestDist and dist < 50 then
                                            nearestDist = dist
                                            nearestVehicle = car
                                        end
                                    end
                                end
                            end
                        end
                        if nearestVehicle then
                            for _, desc in ipairs(nearestVehicle:GetDescendants()) do
                                if desc:IsA('ProximityPrompt') and desc.Enabled then
                                    pcall(function() desc:InputHoldBegin() end)
                                    task.wait(0.2)
                                    pcall(function() desc:InputHoldEnd() end)
                                    break
                                end
                            end
                        end
                    end)
                end
                WasInVehicle = isCurrentlyInVehicle
            end
            task.wait(1)
        else
            WasInVehicle = false
            task.wait(2)
        end
    end
end)

print('[KillSystem v10.53] 反弹出客户端监控版已加载。')

-- ==========================================
-- [战斗状态控制系统 - v10.58d恢复旧版协议]
-- 基于 combatMode 协议：
--   FireServer("combatMode", true)  = 永久战斗状态（不会自动消失）
--   FireServer("combatMode", false) = 启动40秒倒计时，40秒后变为非战斗
-- v10.53纯客户端版曾改为 SetAttribute，但实测无法影响服务端战斗判定
-- v10.58d恢复 v10.42 的 FireServer 实现：
--   永久战斗模式：每30秒发送一次 FireServer("combatMode", true)（保险防失效）
--   永久免战模式：事件驱动 - 监听 OnClientEvent 中的 combatMode 事件
--                  战斗被触发时才发送一次 false（启动40秒倒计时退出战斗）
-- ==========================================
local CombatControlLastSend = 0

-- 永久战斗模式：循环发包
task.spawn(function()
    while true do
        if Config.PermanentCombat_Enabled then
            if tick() - CombatControlLastSend >= 30 then
                CombatControlLastSend = tick()
                local remote = FetchRemote()
                if remote then
                    pcall(function() remote:FireServer("combatMode", true) end)
                end
            end
            task.wait(1)
        else
            task.wait(2)
        end
    end
end)

-- 永久免战模式：事件驱动拦截（OnClientEvent 监听）
-- 当服务器推送 combatMode 事件（表示战斗被触发）时，发送一次 false 启动倒计时
-- 注意：不能频繁发送 false（会重置40秒计时），只在战斗触发时发送一次
task.spawn(function()
    local remote = FetchRemote()
    if not remote then
        task.wait(3)
        remote = FetchRemote()
    end
    if not remote then return end

    remote.OnClientEvent:Connect(function(eventName, ...)
        -- 永久免战模式：检测到服务器推送 combatMode 事件（战斗被触发）时发送一次 false
        if Config.PermanentAntiCombat_Enabled and not Config.PermanentCombat_Enabled
            and eventName == "combatMode" then
            local combatMsg = ...
            -- 服务器推送 combatMode 带字符串消息表示战斗开始
            -- 只在战斗开始时发送 false（取消战斗），避免重复发送重置计时
            if combatMsg then
                task.spawn(function()
                    task.wait(0.1)  -- 稍微延迟避免与服务器事件冲突
                    local r = FetchRemote()
                    if r then
                        pcall(function() r:FireServer("combatMode", false) end)
                        if Config.DebugMode_Enabled then
                            print("[战斗控制] 检测到战斗触发，已发送 combatMode,false 启动40秒倒计时")
                        end
                    end
                end)
            end
        end
    end)
end)

-- ==========================================
-- [自动装备武器系统 - v10.53纯客户端版]
-- ==========================================
-- [自动装备武器系统 - 基于equipItem协议]
-- 协议说明：
--   equipItem, toolInstance = 装备指定工具实例
-- 实现策略：
--   当近战或远程攻击激活时，检测是否已装备武器
--   如果未装备，自动寻找背包中的第一个武器并发送equipItem
-- ==========================================
local function IsWeaponEquipped()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then return true end
        if item:IsA("Model") and item:FindFirstChild("Handle") then return true end
    end
    return false
end

local function FindAndEquipWeapon()
    local char = LocalPlayer.Character
    if not char then return false end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end

    -- 优先寻找枪械类武器（有GUN配置）
    local weapons = {}
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(weapons, item)
        end
    end

    -- 如果背包没有，检查角色（可能已装备但检测失败）
    if #weapons == 0 then return false end

    -- 优先选择有Config且Config.GUN存在的武器
    local bestWeapon = nil
    for _, w in ipairs(weapons) do
        local cfg = w:FindFirstChild("Config")
        if cfg then
            local success, cfgData = pcall(require, cfg)
            if success and cfgData and cfgData.GUN then
                bestWeapon = w
                break
            end
        end
    end
    -- 没有枪械就选第一个工具
    if not bestWeapon then bestWeapon = weapons[1] end

    if bestWeapon then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild('Humanoid') then
            pcall(function() char.Humanoid:EquipTool(bestWeapon) end)
            return true
        end
    end
    return false
end

-- 自动装备检测循环：当攻击功能激活且未装备武器时自动装备
local AutoEquipLastCheck = 0
task.spawn(function()
    while true do
        if Config.AutoEquipWeapon_Enabled and (Config.Melee_Enabled or Config.Ranged_Enabled) then
            -- 每2秒检查一次，避免高频发包
            if tick() - AutoEquipLastCheck >= 2 then
                AutoEquipLastCheck = tick()
                if not IsWeaponEquipped() then
                    FindAndEquipWeapon()
                end
            end
            task.wait(1)
        else
            task.wait(2)
        end
    end
end)

print('[KillSystem v10.53] 纯客户端武器装备版已加载。')
-- ==========================================

print('[KillSystem v10.53] 移动与实用工具版已加载。')

-- 无限跳跃：检测跳跃按键时重置跳跃状态
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump_Enabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- 防受伤抖动：Hook Camera CFrame，抵消抖动
local OriginalCameraCFrame = nil

-- 点击传送：鼠标右键点击地面位置传送
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if Config.ClickTeleport_Enabled and not gameProcessed then
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Hit
            if target then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    -- 传送到位击位置（向上偏移3 studs避免卡在地面）
                    char.HumanoidRootPart.CFrame = target * CFrame.new(0, 3, 0)
                end
            end
        end
    end
end)

print('[KillSystem v10.53] 传送与跳跃版已加载。')

-- ==========================================
-- [锁定绘制残留监控 - 持续强制清理]
-- 修复：即使Melee/Ranged关闭，残留的task.spawn可能仍会创建Highlight
-- 此Heartbeat持续监控，功能关闭时强制清理所有锁定Highlight
-- ==========================================
local LockVisualCleanupLastCheck = 0

print('[KillSystem v10.53] 锁定绘制修复版已加载。')

-- ==========================================
-- [自瞄系统 - 全参数可调]
-- 实现摄像机平滑转向目标，支持FOV/预测/目标选择
-- ==========================================

-- FOV圆圈绘制
local FOVCircle = nil
local function UpdateFOVCircle()
    if Config.Aimbot_ShowFOV and Config.Aimbot_Enabled then
        if not FOVCircle or not FOVCircle.Parent then
            FOVCircle = Instance.new("Frame")
            FOVCircle.Name = "KillSystem_FOVCircle"
            FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            FOVCircle.BackgroundTransparency = 1
            FOVCircle.BorderSizePixel = 0
            FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
            FOVCircle.ZIndex = 100
            FOVCircle.Parent = ScreenGui
            local corner = Instance.new("UICorner", FOVCircle)
            corner.CornerRadius = UDim.new(1, 0)
            local stroke = Instance.new("UIStroke", FOVCircle)
            stroke.Color = Theme.C1
            stroke.Thickness = 2
            stroke.Transparency = 0.5
        end
        local camera = workspace.CurrentCamera
        if camera then
            local viewportSize = camera.ViewportSize
            FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
            FOVCircle.Size = UDim2.fromOffset(Config.Aimbot_FOV * 2, Config.Aimbot_FOV * 2)
        end
    else
        if FOVCircle and FOVCircle.Parent then
            FOVCircle:Destroy()
            FOVCircle = nil
        end
    end
end

-- 获取自瞄目标
local function GetAimbotTarget()
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return nil end
    local localRoot = localChar.HumanoidRootPart
    local localPos = localRoot.Position
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    local candidates = {}
    local allowedTeams = Config.Melee_AllowedTeams  -- 复用近战的队伍选择

    -- 扫描玩家
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if #allowedTeams > 0 and (not player.Team or not table.find(allowedTeams, player.Team.Name)) then continue end
            if Config.Aimbot_FriendsCheck and LocalPlayer:IsFriendsWith(player.UserId) then continue end

            local targetChar = player.Character
            if targetChar and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 then
                local targetPart = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if screenDist <= Config.Aimbot_FOV then
                            -- 可见性检测
                            local isVisible = true
                            if Config.Aimbot_VisibilityCheck and not Config.Aimbot_WallBang then
                                local params = RaycastParams.new()
                                params.FilterDescendantsInstances = {localChar}
                                params.FilterType = Enum.RaycastFilterType.Exclude
                                local hit = workspace:Raycast(localPos, (targetPart.Position - localPos), params)
                                if hit and not hit.Instance:IsDescendantOf(targetChar) then isVisible = false end
                            end
                            if isVisible or Config.Aimbot_WallBang then
                                table.insert(candidates, {
                                    Player = player,
                                    Char = targetChar,
                                    Part = targetPart,
                                    ScreenDist = screenDist,
                                    WorldDist = (targetPart.Position - localPos).Magnitude,
                                    Health = targetChar.Humanoid.Health
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    -- NPC扫描
    if Config.Aimbot_NPC then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("Model") and not Players:GetPlayerFromCharacter(desc) then
                local hum = desc:FindFirstChildOfClass("Humanoid")
                local root = desc:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 and desc ~= localChar then
                    local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if screenDist <= Config.Aimbot_FOV then
                            table.insert(candidates, {
                                Player = {Name = desc.Name, UserId = 0},
                                Char = desc,
                                Part = root,
                                ScreenDist = screenDist,
                                WorldDist = (root.Position - localPos).Magnitude,
                                Health = hum.Health
                            })
                        end
                    end
                end
            end
        end
    end

    if #candidates == 0 then return nil end

    -- 根据目标选择模式排序
    if Config.Aimbot_TargetMode == 1 then
        -- 最近距离
        table.sort(candidates, function(a, b) return a.WorldDist < b.WorldDist end)
    elseif Config.Aimbot_TargetMode == 2 then
        -- 最低血量
        table.sort(candidates, function(a, b) return a.Health < b.Health end)
    elseif Config.Aimbot_TargetMode == 3 then
        -- 最近屏幕中心
        table.sort(candidates, function(a, b) return a.ScreenDist < b.ScreenDist end)
    end

    return candidates[1]
end

print('[KillSystem v10.53] 自瞄系统版已加载。')

-- [v10.53] 自伤治疗：直接设置Health=MaxHealth
task.spawn(function()
    local lastHealTime = 0
    while true do
        if Config.SelfHeal_Enabled then
            if tick() - lastHealTime >= Config.SelfHeal_Interval then
                lastHealTime = tick()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild('Humanoid') then
                    local hum = char.Humanoid
                    if hum.Health < hum.MaxHealth then
                        pcall(function() hum.Health = hum.MaxHealth end)
                    end
                end
            end
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)






print('[KillSystem v10.53] 安全漏洞利用功能已移除。')

-- ==========================================
-- [强力暴力利用系统 - v10.35新增]
-- 基于新反编译分析，原漏洞因服务端校验失效
-- 这些新功能采用更暴力的方式尝试绕过
-- ==========================================






print('[KillSystem v10.53] 强力暴力利用功能已移除。')

-- ==========================================
-- [纯客户端权威系统 - v10.36新增]
-- 关键发现：GameRules和Framework.Core模块是客户端require的
-- 可以直接修改本地变量，纯客户端生效，不需要服务端验证
-- ==========================================

-- 获取GameRules模块（客户端require的配置表）
local GameRules = nil
local function GetGameRules()
    if GameRules then return GameRules end
    local success, rules = pcall(function()
        return require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("GameRules"))
    end)
    if success then
        GameRules = rules
        return rules
    end
    return nil
end

-- 获取Framework.Core模块（包含stamina/food本地变量）
local FrameworkCore = nil
local function GetFrameworkCore()
    if FrameworkCore then return FrameworkCore end
    local success, core = pcall(function()
        return require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Framework"):WaitForChild("Core"))
    end)
    if success then
        FrameworkCore = core
        return core
    end
    return nil
end

-- 客户端饱食 [v10.61修复] 改为纯客户端设置（不发包，不影响反作弊）
-- 用户反馈："无限饥饿在反作弊那就被开启了，我要的是直接客户端设置"
task.spawn(function()
    while true do
        if Config.ClientFood_Enabled then
            local core = GetFrameworkCore()
            if core then
                -- 同时调用 setCoreStaminaOrFood（本地设置）和直接设置 food 变量
                pcall(function()
                    if core.setCoreStaminaOrFood then
                        core.setCoreStaminaOrFood("food", 100)
                    end
                    core.food = 100
                end)
                -- 同时调用 changeFood(0) 刷新UI
                pcall(function()
                    if core.changeFood then
                        core.changeFood(0)
                    end
                end)
            end
            -- 设置 LocalPlayer 属性（客户端权威）
            pcall(function() LocalPlayer:SetAttribute("Food", 100) end)
            pcall(function() LocalPlayer:SetAttribute("food", 100) end)
            task.wait(Config.ClientFood_Interval)
        else
            task.wait(2)
        end
    end
end)

-- [v10.58d] 强制战斗模式：恢复 FireServer 替代 SetAttribute
-- 高频发送 combatMode,true 让自己和目标都进入战斗状态
-- canCombat 要求双方都开启 CombatMode 才能战斗
task.spawn(function()
    while true do
        if Config.ForceCombatMode_Enabled then
            local remote = FetchRemote()
            if remote then
                pcall(function() remote:FireServer("combatMode", true) end)
            end
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

print('[KillSystem v10.53] 纯客户端权威版已加载。')

-- ==========================================
-- [纯客户端功能保留 - v10.53]
-- ==========================================
-- [v10.53] GetPlayerFunc 已移除（纯客户端版不需要InvokeServer）











-- 12. 清除手机通知
task.spawn(function()
    local lastClearTime = 0
    while true do
        if Config.ClearNotifications_Enabled then
            if tick() - lastClearTime >= 3 then
                lastClearTime = tick()
                pcall(function()
                    local gui = LocalPlayer:FindFirstChild("PlayerGui")
                    if gui then
                        local screenGui = gui:FindFirstChild("ScreenGui")
                        if screenGui then
                            local right = screenGui:FindFirstChild("Right")
                            if right then
                                local bottom = right:FindFirstChild("Bottom")
                                if bottom then
                                    local phone = bottom:FindFirstChild("Phone")
                                    if phone then
                                        local notifs = phone:FindFirstChild("Notifications")
                                        if notifs and notifs:FindFirstChild("Frame") then
                                            for _, v in ipairs(notifs.Frame:GetChildren()) do
                                                if v:IsA("Frame") or v:IsA("TextLabel") then
                                                    pcall(function() v:Destroy() end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(1)
        else
            task.wait(5)
        end
    end
end)

-- ==========================================
-- [自制强力功能 - v10.37新增]
-- ==========================================




print('[KillSystem v10.53] 移动端漏洞功能已移除。')

-- ==========================================
-- [VapeV4暴力功能 - v10.53纯客户端版]
-- ==========================================
-- ==========================================

-- [v10.53] Killaura：直接修改目标Humanoid.Health
task.spawn(function()
    while true do
        if Config.VapeKillaura_Enabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild('HumanoidRootPart') then
                local localPos = char.HumanoidRootPart.Position
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild('HumanoidRootPart') and player.Character:FindFirstChild('Humanoid') then
                        if player.Character.Humanoid.Health > 0 then
                            local dist = (player.Character.HumanoidRootPart.Position - localPos).Magnitude
                            if dist <= Config.VapeKillaura_Range then
                                local damageAmount = 60
                                if Config.BrutalDamage_Enabled then damageAmount = damageAmount * Config.BrutalDamage_Factor end
                                pcall(function() player.Character.Humanoid.Health = player.Character.Humanoid.Health - damageAmount end)
                            end
                        end
                    end
                end
            end
            task.wait(Config.VapeKillaura_Delay)
        else
            task.wait(1)
        end
    end
end)

-- [v10.53] VapeSilentAim：纯相机操控（实现见上方）

-- ==========================================
-- [纯客户端功能 - v10.53]
-- ==========================================







-- 自动翻车复位：unflipVehicle
task.spawn(function()
    local lastUnflipTime = 0
    while true do
        if Config.UnflipVehicle_Enabled then
            if tick() - lastUnflipTime >= 5 then
                lastUnflipTime = tick()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local localPos = char.HumanoidRootPart.Position
                    local vehicles = workspace:FindFirstChild("Gameplay") and workspace.Gameplay:FindFirstChild("Vehicles")
                    if vehicles then
                        for _, car in ipairs(vehicles:GetChildren()) do
                            if car:IsA("Model") and car.PrimaryPart then
                                local dist = (car.PrimaryPart.Position - localPos).Magnitude
                                if dist < 30 then
                                    -- 检测是否翻车（CFrame.UpVector.Y < 0）
                                    if car.PrimaryPart.CFrame.UpVector.Y < 0.3 then
                                        pcall(function()
                                            local pos = car.PrimaryPart.Position
                                            car:PivotTo(CFrame.new(pos))
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(2)
        else
            task.wait(5)
        end
    end
end)







print('[KillSystem v10.53] VapeV4纯客户端版已加载。')

-- ==========================================
-- [真正无敌与暴力杀戮 - v10.39新增]
-- 基于反编译深度分析canCombat/canPenetrate/characterHit函数
-- ==========================================

-- 获取Framework.Shared模块（包含canCombat等函数）
local FrameworkShared = nil
local function GetFrameworkShared()
    if FrameworkShared then return FrameworkShared end
    -- 尝试多种路径获取Algorithms模块（包含canCombat）
    local paths = {
        function() return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Algorithms")) end,
        function() return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CharScope")) end,
    }
    for _, pathFn in ipairs(paths) do
        local success, mod = pcall(pathFn)
        if success and mod and mod.canCombat then
            FrameworkShared = mod
            return mod
        end
    end
    return nil
end

-- Hook canCombat：强制返回true绕过所有战斗限制
-- 修复：持续监控，关闭时恢复原函数
local OriginalCanCombat = nil
local OriginalCanPenetrate = nil
task.spawn(function()
    while true do
        if Config.HookCanCombat_Enabled then
            local mod = GetFrameworkShared()
            if mod and mod.canCombat then
                -- 保存原函数（只保存一次）
                if not OriginalCanCombat then
                    OriginalCanCombat = mod.canCombat
                end
                -- 检查是否已被Hook
                if mod.canCombat == OriginalCanCombat then
                    mod.canCombat = function(...)
                        return true  -- 强制返回true
                    end
                    if ScreenLog then ScreenLog("已Hook canCombat") end
                end
            end
            if mod and mod.canPenetrate then
                if not OriginalCanPenetrate then
                    OriginalCanPenetrate = mod.canPenetrate
                end
                if mod.canPenetrate == OriginalCanPenetrate then
                    mod.canPenetrate = function(...)
                        return true
                    end
                end
            end
        else
            -- 关闭时恢复原函数
            local mod = GetFrameworkShared()
            if mod and OriginalCanCombat and mod.canCombat ~= OriginalCanCombat then
                mod.canCombat = OriginalCanCombat
                if ScreenLog then ScreenLog("已恢复canCombat") end
            end
            if mod and OriginalCanPenetrate and mod.canPenetrate ~= OriginalCanPenetrate then
                mod.canPenetrate = OriginalCanPenetrate
            end
        end
        task.wait(1)
    end
end)

-- [v10.53] 暴力伤害：直接修改目标Humanoid.Health
task.spawn(function()
    while true do
        if Config.BrutalDamage_Enabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild('HumanoidRootPart') then
                local localPos = char.HumanoidRootPart.Position
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild('HumanoidRootPart') and player.Character:FindFirstChild('Humanoid') then
                        if player.Character.Humanoid.Health > 0 then
                            local dist = (player.Character.HumanoidRootPart.Position - localPos).Magnitude
                            if dist < 1000 then
                                local damageFactor = Config.BrutalDamage_Factor
                                if Config.MaxDamageFactor_Enabled then damageFactor = 999 end
                                local baseDamage = Config.AllBodyParts_Enabled and 180 or 30
                                local totalDamage = baseDamage * damageFactor * Config.BrutalDamage_MultiCount
                                pcall(function() player.Character:SetAttribute('BulletProof', nil) end)
                                pcall(function() player.Character.Humanoid.Health = player.Character.Humanoid.Health - totalDamage end)
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)


print('[KillSystem v10.53] 暴力杀戮纯客户端版已加载。')


-- 客户端通知：直接调用Core.notify显示弹窗
task.spawn(function()
    local lastNotifyTime = 0
    while true do
        if Config.ClientNotify_Enabled then
            if tick() - lastNotifyTime >= 5 then
                lastNotifyTime = tick()
                local core = GetFrameworkCore()
                if core and core.notify then
                    pcall(function()
                        core.notify({
                            ["message"] = Config.ClientNotify_Text,
                            ["color"] = "green"
                        })
                    end)
                    print("[客户端] 已发送通知: " .. Config.ClientNotify_Text)
                else
                    -- 备选：直接创建通知UI
                    print("[客户端] Core.notify不可用，文本: " .. Config.ClientNotify_Text)
                end
            end
            task.wait(2)
        else
            task.wait(5)
        end
    end
end)

-- Debug模式：每5秒打印功能状态
task.spawn(function()
    while true do
        if Config.DebugMode_Enabled then
            local core = GetFrameworkCore()
            local rules = GetGameRules()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")

            print("========== [Debug] KillSystem 状态 ==========")
            print("Framework.Core 可用: " .. tostring(core ~= nil))
            if core then
                print("  stamina: " .. tostring(core.stamina))
                print("  food: " .. tostring(core.food))
                print("  isJumpEnabled: " .. tostring(core.isJumpEnabled))
                print("  fallRagdollEnabled: " .. tostring(core.fallRagdollEnabled))
                print("  initialFOV: " .. tostring(core.initialFOV))
            end
            print("GameRules 可用: " .. tostring(rules ~= nil))
            if rules then
                print("  disableAntiCheat: " .. tostring(rules.disableAntiCheat))
                print("  unlockAllGamepasses: " .. tostring(rules.unlockAllGamepasses))
            end
            if hum then
                print("Humanoid:")
                print("  Health: " .. hum.Health .. "/" .. hum.MaxHealth)
                print("  WalkSpeed: " .. hum.WalkSpeed)
                print("  JumpPower: " .. hum.JumpPower)
                print("  PlatformStand: " .. tostring(hum.PlatformStand))
                print("  State: " .. tostring(hum:GetState()))
            end
            if char then
                print("Character 属性:")
                print("  BulletProof: " .. tostring(char:GetAttribute("BulletProof")))
                print("  SpawnProtection: " .. tostring(char:GetAttribute("SpawnProtection")))
                print("  CombatMode: " .. tostring(LocalPlayer:GetAttribute("CombatMode")))
            end
            print("Camera FOV: " .. workspace.CurrentCamera.FieldOfView)
            print("Lighting Brightness: " .. game.Lighting.Brightness)
            print("Lighting ClockTime: " .. game.Lighting.ClockTime)
            print("==============================================")

            task.wait(5)
        else
            task.wait(5)
        end
    end
end)

print('[KillSystem v10.53] 纯客户端终极版已加载。')

-- ==========================================
-- [手机端屏幕日志系统 - v10.41新增]
-- 手机端F9控制台不可用，在屏幕显示日志
-- ==========================================

local ScreenLogGui = nil
local ScreenLogFrame = nil
local ScreenLogLabels = {}
local ScreenLogMessages = {}

-- 屏幕日志函数（全局可用）
function ScreenLog(msg)
    -- 同时输出到控制台
    print("[屏幕日志] " .. msg)
    
    if not Config.ScreenLog_Enabled then return end
    
    -- 创建日志GUI
    if not ScreenLogGui or not ScreenLogGui.Parent then
        ScreenLogGui = Instance.new("ScreenGui")
        ScreenLogGui.Name = "KillSystem_ScreenLog"
        ScreenLogGui.ResetOnSpawn = false
        ScreenLogGui.DisplayOrder = 998
        pcall(function() ScreenLogGui.Parent = CoreGui end)
        if not ScreenLogGui.Parent then
            ScreenLogGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end

        ScreenLogFrame = Instance.new("Frame")
        ScreenLogFrame.Size = UDim2.new(0, 400, 0, 200)
        ScreenLogFrame.Position = UDim2.new(0, 10, 0, 10)
        ScreenLogFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ScreenLogFrame.BackgroundTransparency = 0.5
        ScreenLogFrame.BorderSizePixel = 0
        ScreenLogFrame.Parent = ScreenLogGui
        Instance.new("UICorner", ScreenLogFrame).CornerRadius = UDim.new(0, 8)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 20)
        title.BackgroundTransparency = 1
        title.Text = "📋 KillSystem 日志"
        title.TextColor3 = Color3.fromRGB(0, 255, 200)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = ScreenLogFrame

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = ScreenLogFrame
    end

    -- 添加消息
    table.insert(ScreenLogMessages, os.date("%H:%M:%S") .. " " .. msg)
    if #ScreenLogMessages > Config.ScreenLog_MaxLines then
        table.remove(ScreenLogMessages, 1)
    end

    -- 清除旧标签
    for _, label in ipairs(ScreenLogLabels) do
        if label and label.Parent then label:Destroy() end
    end
    ScreenLogLabels = {}

    -- 创建新标签
    for i, msg in ipairs(ScreenLogMessages) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 16)
        label.BackgroundTransparency = 1
        label.Text = msg
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.LayoutOrder = i
        label.Parent = ScreenLogFrame
        table.insert(ScreenLogLabels, label)
    end
end

ScreenLog('KillSystem v10.53 纯客户端版已加载')
print('[KillSystem v10.53] 纯客户端修复版已加载。')

-- ==========================================
-- [统一帧循环系统 - v10.43新增]
-- 将所有46个RunService连接合并为3个统一处理器
-- 使用帧计数器和时间节流减少每帧计算量
-- ==========================================

local UnifiedFrameCount = 0
local CachedChar = nil
local CachedHum = nil
local CachedRoot = nil

-- 缓存角色引用，避免每帧FindFirstChild
local function RefreshCharacterCache()
    local char = LocalPlayer.Character
    if char ~= CachedChar then
        CachedChar = char
        CachedHum = char and char:FindFirstChild("Humanoid") or nil
        CachedRoot = char and char:FindFirstChild("HumanoidRootPart") or nil
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    CachedChar = char
    CachedHum = char:FindFirstChild("Humanoid")
    CachedRoot = char:FindFirstChild("HumanoidRootPart")
    if not CachedHum then
        char:WaitForChild("Humanoid")
        CachedHum = char:FindFirstChild("Humanoid")
    end
    if not CachedRoot then
        char:WaitForChild("HumanoidRootPart")
        CachedRoot = char:FindFirstChild("HumanoidRootPart")
    end
end)

-- ESP节流计时器
local ESPLastUpdate = 0
local ESP_UPDATE_INTERVAL = 1/12  -- ~12Hz

-- Lighting扫描计时器
local LightingScanLastCheck = 0
local LIGHTING_SCAN_INTERVAL = 1  -- 1Hz

-- Player扫描计时器
local PlayerScanLastCheck = 0
local PLAYER_SCAN_INTERVAL = 0.5  -- 2Hz

-- Defense系统计数器
local DefenseCounter = 0

-- ========== Unified Stepped Handler ==========
-- Noclip必须在Stepped中执行（物理引擎之前）
-- [v10.61修复] 不再扫描附近所有车辆（导致车辆掉地底）
-- 只处理玩家自身部件 + 当前驾驶的车辆（如果有seat连接）
RunService.Stepped:Connect(function()
    if Config.Noclip_Enabled then
        RefreshCharacterCache()
        if CachedChar then
            -- 1. Character parts（玩家自身部件）
            for _, part in ipairs(CachedChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    pcall(function() part.CollisionGroup = "Default" end)
                end
            end

            -- 2. 当前驾驶的车辆（仅检测seat连接的车辆，不扫描全图）
            if CachedRoot then
                local seat = CachedChar:FindFirstChild("Seat")
                if seat and seat:IsA("Weld") and seat.Part1 then
                    local vehicle = seat.Part1.Parent
                    if vehicle then
                        for _, part in ipairs(vehicle:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                pcall(function() part.CollisionGroup = "Default" end)
                            end
                        end
                    end
                end
                -- [v10.61修复] 移除 workspace:GetDescendants() 全图扫描
                -- [v10.61修复] 移除 50米范围内所有车辆 CanCollide=false（导致未驾驶车辆掉地底）
            end
        end
    end
end)

-- ========== Unified Heartbeat Handler ==========
RunService.Heartbeat:Connect(function()
    UnifiedFrameCount = UnifiedFrameCount + 1
    RefreshCharacterCache()
    
    local fc = UnifiedFrameCount
    
    -- ===== 每帧（60Hz）：关键强制状态 =====
    
    -- 速度增强
    if Config.Speed_Enabled and CachedHum then
        if CachedHum.WalkSpeed ~= Config.Speed_Value then
            CachedHum.WalkSpeed = Config.Speed_Value
        end
    end
    
    -- 跳跃增强（修复：设置UseJumpPower=true）
    if Config.JumpPower_Enabled and CachedHum then
        CachedHum.UseJumpPower = true
        if CachedHum.JumpPower ~= Config.JumpPower_Value then
            CachedHum.JumpPower = Config.JumpPower_Value
        end
    end
    
    -- 防坠落伤害（v10.44修复：三重防护）
    if Config.NoFall_Enabled and CachedHum then
        local state = CachedHum:GetState()
        -- Method 1: Cancel falling states
        if state == Enum.HumanoidStateType.FallingDown then
            CachedHum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        -- Method 2: Use BodyVelocity to cap downward speed
        if CachedRoot then
            if state == Enum.HumanoidStateType.Freefall then
                local bv = CachedRoot:FindFirstChild("KillSystem_NoFallBV")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "KillSystem_NoFallBV"
                    bv.MaxForce = Vector3.new(0, math.huge, 0)
                    bv.Velocity = Vector3.new(0, -20, 0)  -- Cap fall speed
                    bv.Parent = CachedRoot
                end
            else
                local bv = CachedRoot:FindFirstChild("KillSystem_NoFallBV")
                if bv then bv:Destroy() end
            end
        end
        -- Method 3: Hook fallRagdollEnabled
        local core = GetFrameworkCore()
        if core and core.fallRagdollEnabled ~= false then
            core.fallRagdollEnabled = false
        end
    end
    
    -- Vape Velocity：防击退
    if Config.VapeVelocity_Enabled and CachedRoot then
        local vel = CachedRoot.AssemblyLinearVelocity
        CachedRoot.AssemblyLinearVelocity = Vector3.new(
            vel.X * Config.VapeVelocity_X,
            vel.Y * Config.VapeVelocity_Y,
            vel.Z * Config.VapeVelocity_Z
        )
    end
    

    
    -- ===== 每2帧（30Hz）：防御系统 =====
    if fc % 2 == 0 then
        DefenseCounter = DefenseCounter + 1
        
        -- 反强制Ragdoll：持续强制PlatformStand=false、重新启用Motor6D
        if Config.AntiRagdoll_Enabled and CachedHum then
            if CachedHum.PlatformStand then
                CachedHum.PlatformStand = false
            end
            if CachedChar then
                for _, motor in ipairs(CachedChar:GetDescendants()) do
                    if motor:IsA("Motor6D") and not motor.Enabled then
                        motor.Enabled = true
                    end
                end
            end
            -- GettingUp状态（每60帧调一次）
            if DefenseCounter % 30 == 0 then
                local state = CachedHum:GetState()
                if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.FallingDown then
                    CachedHum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end
        
        -- 快速起身
        if Config.FastGetUp_Enabled and CachedHum then
            local state = CachedHum:GetState()
            local needGetUp = false
            if state == Enum.HumanoidStateType.Physics then
                needGetUp = true
            elseif state == Enum.HumanoidStateType.FallingDown then
                needGetUp = true
            elseif CachedHum.PlatformStand then
                needGetUp = true
            end
            if needGetUp then
                CachedHum.PlatformStand = false
                CachedHum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
        
        -- 反死亡视觉
        if Config.NoKilledVisual_Enabled then
            local cc = game.Lighting:FindFirstChild("KilledColorCorrection")
            if cc and cc.Enabled then
                cc.Enabled = false
                cc.Brightness = 0
                cc.Contrast = 0
                cc.Saturation = 0
            end
        end
        
        -- 反强制隐藏：持续监控TouchControlsEnabled
        if Config.AntiCharHidden_Enabled then
            if not GuiService.TouchControlsEnabled then
                GuiService.TouchControlsEnabled = true
            end
        end
    end
    
    -- ===== 每6帧（10Hz）：半关键功能 =====
    if fc % 6 == 0 then

        

        

        
        -- VapeHitbox：扩大命中箱
        if Config.VapeHitbox_Enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root and root:IsA("BasePart") then
                        if root.Size.X < Config.VapeHitbox_Size then
                            root.Size = Vector3.new(Config.VapeHitbox_Size, Config.VapeHitbox_Size, Config.VapeHitbox_Size)
                        end
                        local head = player.Character:FindFirstChild("Head")
                        if head and head:IsA("BasePart") and head.Size.X < Config.VapeHitbox_Size then
                            head.Size = Vector3.new(Config.VapeHitbox_Size, Config.VapeHitbox_Size, Config.VapeHitbox_Size)
                        end
                    end
                end
            end
        end
        

        
        -- FOV修改/相机FOV
        if Config.FOVModify_Enabled or Config.CameraFOV_Enabled then
            local camera = workspace.CurrentCamera
            if camera then
                local fov = Config.FOVModify_Enabled and Config.FOVModify_Value or Config.CameraFOV_Value
                if camera.FieldOfView ~= fov then
                    camera.FieldOfView = fov
                end
            end
            local core = GetFrameworkCore()
            if core then
                core.initialFOV = Config.FOVModify_Enabled and Config.FOVModify_Value or Config.CameraFOV_Value
            end
        end
        
        -- 无跳跃限制
        if Config.NoJumpLimit_Enabled then
            local core = GetFrameworkCore()
            if core and not core.isJumpEnabled then
                core.isJumpEnabled = true
            end
            if CachedHum then
                CachedHum.UseJumpPower = true
                CachedHum.JumpPower = 100
            end
        end
        
        -- 防Ragdoll（v10.40）：设置Core.fallRagdollEnabled=false
        if Config.AntiRagdoll_Enabled then
            local core = GetFrameworkCore()
            if core and core.fallRagdollEnabled ~= false then
                core.fallRagdollEnabled = false
            end
            if CachedHum then
                if CachedHum.PlatformStand then
                    CachedHum.PlatformStand = false
                end
                local state = CachedHum:GetState()
                if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.FallingDown then
                    CachedHum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end
        
        -- 客户端移速
        if Config.ClientWalkSpeed_Enabled then
            local rules = GetGameRules()
            if rules and rules.humanoidStateParameters then
                for _, params in pairs(rules.humanoidStateParameters) do
                    if params.WalkSpeed ~= Config.ClientWalkSpeed_Value then
                        pcall(function() params.WalkSpeed = Config.ClientWalkSpeed_Value end)
                    end
                end
            end
            if CachedHum and CachedHum.WalkSpeed ~= Config.ClientWalkSpeed_Value then
                CachedHum.WalkSpeed = Config.ClientWalkSpeed_Value
            end
        end
        
        -- 客户端游泳速度
        if Config.ClientSwimSpeed_Enabled then
            local rules = GetGameRules()
            if rules and rules.humanoidStateParameters then
                for _, params in pairs(rules.humanoidStateParameters) do
                    if params.SwimSpeed ~= Config.ClientSwimSpeed_Value then
                        pcall(function() params.SwimSpeed = Config.ClientSwimSpeed_Value end)
                    end
                end
            end
        end
    end
    
    -- ===== 每30帧（2Hz）：低优先级功能 =====
    if fc % 30 == 0 then
        -- 禁用反作弊
        if Config.DisableAntiCheat_Enabled then
            local rules = GetGameRules()
            if rules and rules.disableAntiCheat ~= true then
                rules.disableAntiCheat = true
            end
        end
        
        -- 解锁所有Gamepass
        if Config.UnlockGamepasses_Enabled then
            local rules = GetGameRules()
            if rules and rules.unlockAllGamepasses ~= true then
                rules.unlockAllGamepasses = true
            end
        end
        
        -- 禁用通缉等级
        if Config.DisableWanted_Enabled then
            local rules = GetGameRules()
            if rules and rules.disableWantedLevel ~= true then
                rules.disableWantedLevel = true
            end
        end
        
        -- 允许购买任意物品
        if Config.AllowBuyAnyItem_Enabled then
            local rules = GetGameRules()
            if rules and rules.allowToBuyAnyItem ~= true then
                rules.allowToBuyAnyItem = true
            end
        end
        
        -- 客户端体力 [v10.61修复] 改为纯客户端设置（不发包，不影响反作弊）
        -- 用户反馈："无限体力在反作弊那就被开启了，我要的是直接客户端设置"
        -- 实现：同时设置 Core.stamina + LocalPlayer:SetAttribute("Stamina")
        if Config.ClientStamina_Enabled then
            local core = GetFrameworkCore()
            if core then
                if core.stamina ~= 100 then
                    pcall(function() core.stamina = 100 end)
                end
                -- 调用本地 setCoreStaminaOrFood（不发包只设置本地）
                if core.setCoreStaminaOrFood then
                    pcall(function() core.setCoreStaminaOrFood("stamina", 100) end)
                end
            end
            -- 设置 LocalPlayer 属性（客户端权威，不触发反作弊）
            pcall(function() LocalPlayer:SetAttribute("Stamina", 100) end)
            pcall(function() LocalPlayer:SetAttribute("stamina", 100) end)
        end
        
        -- [v10.58d] 永久战斗模式已迁移到独立的 FireServer 循环（见上文"战斗状态控制系统"）
        -- 此处不再使用 SetAttribute（实测无法影响服务端战斗判定）
        
        -- [v10.45修复] 自动装备武器：检测未装备时自动装备背包中的武器
        if Config.AutoEquipWeapon_Enabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local hasEquipped = false
                for _, item in ipairs(char:GetChildren()) do
                    if item:IsA("Tool") then hasEquipped = true break end
                end
                if not hasEquipped then
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    if backpack then
                        for _, item in ipairs(backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                pcall(function() hum:EquipTool(item) end)
                                break
                            end
                        end
                    end
                end
            end
        end
        
        -- 快捷键透明度同步
        for _, shortcut in ipairs(State.Shortcuts) do
            if shortcut and shortcut.Parent then
                local key = shortcut:GetAttribute("ConfigKey")
                if key and Config[key] ~= nil then
                    local targetTransparency = Config[key] and 0.2 or 0.5
                    if shortcut.BackgroundTransparency ~= targetTransparency then
                        shortcut.BackgroundTransparency = targetTransparency
                    end
                end
            end
        end
        
        -- 锁定绘制残留清理
        if not Config.Melee_Enabled then
            if next(State.VisualRegistry.Melee) ~= nil then
                for char, hl in pairs(State.VisualRegistry.Melee) do
                    if hl then pcall(function() hl:Destroy() end) end
                end
                State.VisualRegistry.Melee = {}
            end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Highlight") and obj.Name == "KillSystem_MeleeLock" then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        if not Config.Ranged_Enabled then
            if next(State.VisualRegistry.Ranged) ~= nil then
                for char, hl in pairs(State.VisualRegistry.Ranged) do
                    if hl then pcall(function() hl:Destroy() end) end
                end
                State.VisualRegistry.Ranged = {}
            end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Highlight") and obj.Name == "KillSystem_RangedLock" then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        
        -- 无限氧气
        if Config.InfiniteOxygen_Enabled and CachedChar then
            CachedChar:SetAttribute("Oxygen", 100)
        end

        -- 自动重生
        if Config.AutoRespawn_Enabled and CachedHum then
            if CachedHum.Health <= 0 then
                task.spawn(function()
                    task.wait(1)
                    pcall(function() LocalPlayer:LoadCharacter() end)
                end)
            end
        end
        
        -- [v10.53] 反强制隐藏：仅客户端恢复（不再FireServer）
    end
    
    -- ===== 每60帧（1Hz）：极低优先级功能 =====
    if fc % 60 == 0 then
        -- ===== 合并Lighting扫描 =====
        local needLightingScan = Config.AntiBlur_Enabled or Config.AntiColorCorrection_Enabled 
            or Config.AntiBlind_Enabled or Config.Fullbright_Enabled
            or Config.ForceDay_Enabled or Config.ForceNight_Enabled
            or Config.NoFog_Enabled or Config.Brightness_Enabled
            or Config.WeatherControl_Enabled or Config.TimeControl_Enabled
        
        if needLightingScan then
            -- 全亮模式
            if Config.Fullbright_Enabled then
                pcall(function()
                    if game.Lighting.Brightness < 3 then game.Lighting.Brightness = 3 end
                    if game.Lighting.ClockTime ~= 12 then game.Lighting.ClockTime = 12 end
                    if game.Lighting.FogEnd < 100000 then game.Lighting.FogEnd = 100000 end
                    local atm = game.Lighting:FindFirstChildOfClass("Atmosphere")
                    if atm and atm.Haze ~= 0 then atm.Haze = 0 end
                end)
            end
            
            -- 防致盲
            if Config.AntiBlind_Enabled then
                pcall(function()
                    for _, child in ipairs(game.Lighting:GetChildren()) do
                        if child.Name == "KillSystem_Blur" then continue end
                        if child.Name == "KilledColorCorrection" and Config.NoKilledVisual_Enabled then continue end
                        if child:IsA("ColorCorrectionEffect") and child.Brightness > 0.5 then
                            child.Enabled = false
                        end
                        if child:IsA("BloomEffect") and child.Intensity > 1 then
                            child.Enabled = false
                        end
                        if child:IsA("BlurEffect") and child.Size > 10 then
                            child.Enabled = false
                        end
                    end
                end)
            end
            
            -- 防模糊
            if Config.AntiBlur_Enabled then
                for _, child in ipairs(game.Lighting:GetChildren()) do
                    if child.Name == "KillSystem_Blur" then continue end
                    if child:IsA("BlurEffect") and child.Enabled then
                        child.Enabled = false
                    end
                end
            end
            
            -- 防色彩校正
            if Config.AntiColorCorrection_Enabled then
                for _, child in ipairs(game.Lighting:GetChildren()) do
                    if child:IsA("ColorCorrectionEffect") and child.Enabled then
                        child.Enabled = false
                    end
                end
            end
            
            -- 强制白天
            if Config.ForceDay_Enabled then
                game.Lighting.ClockTime = 12
                game.Lighting.Brightness = 3
            end
            
            -- 强制夜晚
            if Config.ForceNight_Enabled then
                game.Lighting.ClockTime = 0
                game.Lighting.Brightness = 1
            end
            
            -- 无雾
            if Config.NoFog_Enabled then
                game.Lighting.FogEnd = 100000
                local atm = game.Lighting:FindFirstChildOfClass("Atmosphere")
                if atm then atm.Haze = 0 end
            end
            
            -- 亮度增强
            if Config.Brightness_Enabled then
                game.Lighting.Brightness = Config.Brightness_Value
                if game.Lighting.ClockTime < 6 or game.Lighting.ClockTime > 18 then
                    game.Lighting.ClockTime = 12
                end
            end
            
            -- 天气控制
            if Config.WeatherControl_Enabled then
                pcall(function()
                    if Config.WeatherControl_Type == "Sunny" then
                        Lighting.Brightness = 3
                        Lighting.ClockTime = 12
                        Lighting.FogEnd = 100000
                        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
                        if atm then atm.Haze = 0 atm.Density = 0.3 end
                    elseif Config.WeatherControl_Type == "Rainy" then
                        Lighting.Brightness = 1
                        Lighting.ClockTime = 10
                        Lighting.FogEnd = 5000
                        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
                        if atm then atm.Haze = 2 atm.Density = 0.6 end
                    elseif Config.WeatherControl_Type == "Night" then
                        Lighting.Brightness = 1
                        Lighting.ClockTime = 0
                        Lighting.FogEnd = 20000
                    end
                end)
            end
            
            -- 时间控制
            if Config.TimeControl_Enabled then
                pcall(function()
                    Lighting.ClockTime = Config.TimeControl_Hour
                end)
            end
        end
        
        -- 本地风场破坏
        if Config.WindChaos_Enabled then
            pcall(function()
                workspace:SetAttribute("WindPower", 9999)
                workspace:SetAttribute("WindSpeed", 9999)
                workspace.GlobalWind = Vector3.new(999, 999, 999)
            end)
        end
        
        -- ===== 合并Player扫描 =====
        local needPlayerScan = Config.AntiSpawnProtect_Enabled
        if needPlayerScan then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    -- 移除出生保护
                    if Config.AntiSpawnProtect_Enabled then
                        if player.Character:GetAttribute("SpawnProtection") then
                            player.Character:SetAttribute("SpawnProtection", nil)
                        end
                        if player.Character:GetAttribute("BulletProof") then
                            player.Character:SetAttribute("BulletProof", nil)
                        end
                    end
                end
            end
        end
        
        -- 屏幕日志关闭时清理
        if not Config.ScreenLog_Enabled and ScreenLogGui and ScreenLogGui.Parent then
            ScreenLogGui:Destroy()
            ScreenLogGui = nil
            ScreenLogFrame = nil
            ScreenLogLabels = {}
            ScreenLogMessages = {}
        end
    end
end)
-- ==========================================
-- ==========================================
-- [纯客户端新增功能 - v10.53]
-- ==========================================

-- [v10.53] PropertyHack：直接修改武器Config.Ammo
task.spawn(function()
    while true do
        if Config.PropertyHack_Enabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA('Tool') then
                            local cfgModule = tool:FindFirstChild('Config')
                            if cfgModule then
                                local success, cfg = pcall(require, cfgModule)
                                if success and cfg and cfg.GUN then
                                    pcall(function() cfg.GUN.CURRENT_AMMO = Config.PropertyHack_Value end)
                                    pcall(function() cfg.GUN.RESERVE_AMMO = Config.PropertyHack_Value end)
                                    pcall(function() cfg.GUN.MAGAZINE_SIZE = Config.PropertyHack_Value end)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        else
            task.wait(5)
        end
    end
end)

-- [v10.53] UnflipVehicle：直接CFrame操控
task.spawn(function()
    local lastUnflipTime = 0
    while true do
        if Config.UnflipVehicle_Enabled then
            if tick() - lastUnflipTime >= 5 then
                lastUnflipTime = tick()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild('HumanoidRootPart') then
                    local localPos = char.HumanoidRootPart.Position
                    local vehicles = workspace:FindFirstChild('Gameplay') and workspace.Gameplay:FindFirstChild('Vehicles')
                    if vehicles then
                        for _, car in ipairs(vehicles:GetChildren()) do
                            if car:IsA('Model') and car.PrimaryPart then
                                local dist = (car.PrimaryPart.Position - localPos).Magnitude
                                if dist < 30 then
                                    if car.PrimaryPart.CFrame.UpVector.Y < 0.3 then
                                        pcall(function()
                                            local pos = car.PrimaryPart.Position
                                            car:PivotTo(CFrame.new(pos))
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(2)
        else
            task.wait(5)
        end
    end
end)

-- [v10.53] FocusCamera：Camera.CFrame操控
task.spawn(function()
    local lastFocusTime = 0
    while true do
        if Config.FocusCamera_Enabled then
            if tick() - lastFocusTime >= 0.1 then
                lastFocusTime = tick()
                local char = LocalPlayer.Character
                local camera = workspace.CurrentCamera
                if char and char:FindFirstChild('HumanoidRootPart') and camera then
                    local localPos = char.HumanoidRootPart.Position
                    local nearestPlayer = nil
                    local nearestDist = math.huge
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
                            local dist = (player.Character.HumanoidRootPart.Position - localPos).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearestPlayer = player
                            end
                        end
                    end
                    if nearestPlayer and nearestPlayer.Character:FindFirstChild('Head') then
                        local targetPos = nearestPlayer.Character.Head.Position
                        local currentPos = camera.CFrame.Position
                        camera.CFrame = CFrame.new(currentPos, targetPos)
                    end
                end
            end
            task.wait(0.05)
        else
            task.wait(2)
        end
    end
end)
-- ========== Unified RenderStepped Handler ==========
RunService.RenderStepped:Connect(function()
    -- ===== 每帧：相机相关功能 =====
    
    -- [v10.51增强] 飞行系统：BodyVelocity + BodyGyro + 手机端适配
    if Config.Fly_Enabled then
        local char = CachedChar or LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local camera = workspace.CurrentCamera
            if root and camera then
                local bv = root:FindFirstChild("KillSystem_FlyBV")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "KillSystem_FlyBV"
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = root
                end

                local bg = root:FindFirstChild("KillSystem_FlyBG")
                if not bg then
                    bg = Instance.new("BodyGyro")
                    bg.Name = "KillSystem_FlyBG"
                    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bg.CFrame = root.CFrame
                    bg.Parent = root
                end

                local flySpeed = Config.Fly_Speed
                local moveVector = Vector3.new(0, 0, 0)

                if State.IsMobile then
                    -- [手机端] 读取游戏内置摇杆方向（Humanoid.MoveDirection）
                    -- 摇杆推前=LookVector方向，推左=-RightVector方向
                    -- [v10.63修复] 即使摇杆未推动，只要按住上升/下降按钮也要飞行
                    local hum = char:FindFirstChild("Humanoid")
                    if hum and hum.MoveDirection.Magnitude > 0.01 then
                        -- MoveDirection是世界坐标方向，需要映射到相机坐标系
                        -- MoveDirection.X = 左右, MoveDirection.Z = 前后(负=前)
                        local camCF = camera.CFrame
                        local forward = camCF.LookVector
                        local right = camCF.RightVector
                        -- MoveDirection: X=右为正, Z=前为负(Roblox convention)
                        moveVector = right * hum.MoveDirection.X + forward * (-hum.MoveDirection.Z)
                        -- 归一化后乘以飞行速度
                        if moveVector.Magnitude > 0 then
                            moveVector = moveVector.Unit * flySpeed
                        end
                    end
                    -- 虚拟按钮控制上下
                    -- [v10.63关键修复] 按住上升/下降按钮时强制施加Y轴速度
                    -- 即使摇杆没推动也要让 BodyVelocity 有 Y 分量
                    if State.MobileFlyUp then
                        moveVector = moveVector + Vector3.new(0, flySpeed, 0)
                    end
                    if State.MobileFlyDown then
                        moveVector = moveVector - Vector3.new(0, flySpeed, 0)
                    end
                    -- [v10.63] 调试：当按下按钮时打印状态（仅 DebugMode）
                    if Config.DebugMode_Enabled and (State.MobileFlyUp or State.MobileFlyDown) then
                        -- 每秒打印一次，避免刷屏
                        if not State._lastFlyDebug or tick() - State._lastFlyDebug > 1 then
                            State._lastFlyDebug = tick()
                            print(string.format("[KillSystem Fly] Up=%s Down=%s moveVec=(%0.1f,%0.1f,%0.1f)",
                                tostring(State.MobileFlyUp), tostring(State.MobileFlyDown),
                                moveVector.X, moveVector.Y, moveVector.Z))
                        end
                    end
                else
                    -- [PC端] 键盘WASD + Space + Shift
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end

                    if moveVector.Magnitude > 0 then
                        moveVector = moveVector.Unit * flySpeed
                    end
                end

                bv.Velocity = moveVector
                bg.CFrame = camera.CFrame
            end
        end
    end
    
    -- [v10.51增强] SAC绕过飞行：BodyPosition + BodyGyro + SAC=true + 手机端适配
    if Config.SACFly_Enabled then
        local char = CachedChar or LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local camera = workspace.CurrentCamera
            if root and camera then
                local bp = root:FindFirstChild("KillSystem_SACFlyBP")
                if not bp then
                    bp = Instance.new("BodyPosition")
                    bp.Name = "KillSystem_SACFlyBP"
                    bp:SetAttribute("SAC", true)
                    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bp.Position = root.Position
                    bp.Parent = root
                end

                local bg = root:FindFirstChild("KillSystem_SACFlyBG")
                if not bg then
                    bg = Instance.new("BodyGyro")
                    bg.Name = "KillSystem_SACFlyBG"
                    bg:SetAttribute("SAC", true)
                    bg.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
                    bg.CFrame = root.CFrame
                    bg.Parent = root
                end

                if char:FindFirstChild("Humanoid") then
                    -- [v10.51修复] 手机端SACFly：不设PlatformStand，保持摇杆MoveDirection可用
                    -- PC端仍设PlatformStand防止行走动画抖动
                    if not State.IsMobile then
                        char.Humanoid.PlatformStand = true
                    end
                end

                local flyCFrame = bg.CFrame - bg.CFrame.Position + bp.Position

                if State.IsMobile then
                    -- [手机端] 读取游戏内置摇杆方向（MoveDirection）
                    -- 因为手机端不设PlatformStand，MoveDirection可以正常更新
                    local hum = char:FindFirstChild("Humanoid")
                    if hum and hum.MoveDirection.Magnitude > 0.01 then
                        local camCF = camera.CFrame
                        local forward = camCF.LookVector
                        local right = camCF.RightVector
                        local worldMove = right * hum.MoveDirection.X + forward * (-hum.MoveDirection.Z)
                        if worldMove.Magnitude > 0 then
                            flyCFrame = flyCFrame + worldMove.Unit * 5
                        end
                    end
                    -- 虚拟按钮控制上下
                    if State.MobileFlyUp then
                        flyCFrame = flyCFrame + Vector3.new(0, 5, 0)
                    end
                    if State.MobileFlyDown then
                        flyCFrame = flyCFrame - Vector3.new(0, 5, 0)
                    end
                else
                    -- [PC端] 键盘控制
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        flyCFrame = flyCFrame + camera.CFrame.LookVector * 5
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        flyCFrame = flyCFrame - camera.CFrame.LookVector * 5
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        flyCFrame = flyCFrame * CFrame.new(5, 0, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        flyCFrame = flyCFrame * CFrame.new(-5, 0, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        flyCFrame = flyCFrame + Vector3.new(0, 5, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        flyCFrame = flyCFrame - Vector3.new(0, 5, 0)
                    end
                end

                bp.Position = flyCFrame.Position
                bg.CFrame = camera.CFrame
            end
        end
    end
    
    -- 自瞄系统
    if Config.Aimbot_Enabled then
        UpdateFOVCircle()

        local shouldAim = true
        if Config.Aimbot_RightClickOnly then
            shouldAim = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        end

        if shouldAim then
            local target = GetAimbotTarget()
            if target then
                local camera = workspace.CurrentCamera
                if camera then
                    local localChar = CachedChar or LocalPlayer.Character
                    if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                        local lockPart = target.Char
                        if Config.Aimbot_LockHead then
                            lockPart = target.Char:FindFirstChild("Head") or target.Char:FindFirstChild("HumanoidRootPart")
                        else
                            lockPart = target.Char:FindFirstChild("HumanoidRootPart") or target.Char:FindFirstChild("Head")
                        end
                        if lockPart then
                            local targetPos = lockPart.Position
                            if Config.Aimbot_Prediction > 0 then
                                local targetRoot = target.Char:FindFirstChild("HumanoidRootPart")
                                if targetRoot then
                                    targetPos = targetPos + targetRoot.Velocity * Config.Aimbot_Prediction
                                end
                            end

                            local currentCFrame = camera.CFrame
                            local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)

                            local smoothness = Config.Aimbot_Smoothness
                            if smoothness <= 0 then
                                camera.CFrame = targetCFrame
                            else
                                camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 - smoothness)
                            end

                        end
                    end
                end
            end
        end
    else
        if FOVCircle and FOVCircle.Parent then
            FOVCircle:Destroy()
            FOVCircle = nil
        end
    end
    
    -- ===== 攻击线生命周期管理 =====
    if #State.AttackLines > 0 then
        local anyEnabled = Config.DrawMeleeLine_Enabled or Config.DrawRangedLine_Enabled
        if not anyEnabled then
            ClearAttackLines()
        else
            local now = tick()
            for i = #State.AttackLines, 1, -1 do
                local lineData = State.AttackLines[i]
                if lineData and now - lineData.creationTime > lineData.duration then
                    if lineData.beamPart then
                        pcall(function() lineData.beamPart:Destroy() end)
                    end
                    table.remove(State.AttackLines, i)
                end
            end
        end
    end
    
    -- ===== ESP节流更新（~12Hz） =====
    if Config.ESP_Enabled then
        local now = tick()
        if now - ESPLastUpdate >= ESP_UPDATE_INTERVAL then
            ESPLastUpdate = now
            UpdateESP()
        end
    end
end)

-- ==========================================
-- [攻击线绘制系统 - 3D Beam优化版]
-- 修复：2D GUI线绘制错误且每条线一个RenderStepped连接导致严重卡顿
-- 改进：1.改回3D Beam（位置准确，无需投影计算）
--       2.[v10.43] 生命周期管理已合并到统一RenderStepped处理器
--       3.限制最大数量20条，超过删除最老的
--       4.关闭开关时立即清理所有Beam实例
--       5.Beam挂在单一容器下，便于统一清理
-- ==========================================
local MAX_ATTACK_LINES = 20  -- 最大同时存在的攻击线数量
local AttackLineContainer = nil  -- Beam容器，延迟创建

-- 获取或创建Beam容器
local function GetAttackLineContainer()
    if AttackLineContainer and AttackLineContainer.Parent then return AttackLineContainer end
    AttackLineContainer = Instance.new("Folder")
    AttackLineContainer.Name = "KillSystem_AttackLines"
    AttackLineContainer.Parent = workspace
    return AttackLineContainer
end

ClearAttackLines = function()
    -- 立即清理所有活跃的攻击线实例
    for _, lineData in ipairs(State.AttackLines) do
        if lineData and lineData.beamPart then
            pcall(function() lineData.beamPart:Destroy() end)
        end
    end
    State.AttackLines = {}
end

DrawAttackLine = function(startPos, endPos, color, duration)
    duration = duration or 0.2
    local container = GetAttackLineContainer()

    -- 如果超过最大数量，删除最老的线
    if #State.AttackLines >= MAX_ATTACK_LINES then
        local oldest = table.remove(State.AttackLines, 1)
        if oldest and oldest.beamPart then
            pcall(function() oldest.beamPart:Destroy() end)
        end
    end

    -- 创建单一锚点Part挂载两个Attachment和Beam
    local beamPart = Instance.new("Part")
    beamPart.Anchored = true
    beamPart.CanCollide = false
    beamPart.CanQuery = false
    beamPart.CanTouch = false
    beamPart.Transparency = 1
    beamPart.Size = Vector3.new(0.1, 0.1, 0.1)
    beamPart.Position = startPos
    beamPart.Parent = container

    local att0 = Instance.new("Attachment")
    att0.Position = Vector3.new(0, 0, 0)
    att0.Parent = beamPart

    local att1 = Instance.new("Attachment")
    -- 相对位置 = endPos - startPos
    att1.Position = endPos - startPos
    att1.Parent = beamPart

    local beam = Instance.new("Beam")
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Color = ColorSequence.new(color)
    beam.Transparency = NumberSequence.new(0.2)
    beam.Width0 = 0.3
    beam.Width1 = 0.3
    beam.FaceCamera = true
    beam.Parent = beamPart

    local lineData = {
        beamPart = beamPart,
        beam = beam,
        creationTime = tick(),
        duration = duration
    }
    table.insert(State.AttackLines, lineData)
end


-- ==========================================
-- [v10.56新增功能实现 - 基于反编译脚本]
-- 全部为纯客户端实现：GameRules覆盖 / AssemblyVelocity限制 / require(Config)篡改
-- ==========================================

-- 共用：获取GameRules模块表（require缓存，所有读取共享同一表）
local function GetGameRulesTable()
    local ok, G = pcall(function()
        return require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameRules"))
    end)
    if ok and type(G) == "table" then return G end
    return nil
end

-- 共用：扫描所有武器Config模块（ReplicatedStorage.Stuff.Weapons.*.Config 与 已装备Tool.Config）
local function ForEachWeaponConfig(fn)
    pcall(function()
        local stuff = game.ReplicatedStorage:FindFirstChild("Stuff")
        if stuff then
            local weapons = stuff:FindFirstChild("Weapons")
            if weapons then
                for _, obj in ipairs(weapons:GetDescendants()) do
                    if obj:IsA("ModuleScript") and obj.Name == "Config" then
                        pcall(fn, obj)
                    end
                end
            end
        end
    end)
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    local cfg = tool:FindFirstChild("Config")
                    if cfg and cfg:IsA("ModuleScript") then
                        pcall(fn, cfg)
                    end
                end
            end
        end
    end)
    pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local cfg = tool:FindFirstChild("Config")
                    if cfg and cfg:IsA("ModuleScript") then
                        pcall(fn, cfg)
                    end
                end
            end
        end
    end)
end

-- [v10.56] 武器配置批量覆盖：RPM/RELOAD_TIME/BULLET_AMOUNT/TR_DIFF/DAMAGE/REST_TIME
task.spawn(function()
    while true do
        if Config.Weapon_RapidFire or Config.Weapon_FastReload or Config.Weapon_ShotgunBoost
            or Config.Weapon_MaxDamage or Config.Weapon_NoMeleeCooldown then
            ForEachWeaponConfig(function(cfgModule)
                local ok, cfg = pcall(require, cfgModule)
                if ok and cfg and type(cfg) == "table" then
                    if Config.Weapon_RapidFire then
                        pcall(function() cfg.RPM = 9999 end)
                    end
                    if Config.Weapon_FastReload then
                        pcall(function() cfg.RELOAD_TIME = 0 end)
                    end
                    if Config.Weapon_ShotgunBoost then
                        pcall(function()
                            if cfg.CATEGORY == "Shotgun" or (cfg.GUN and cfg.GUN.CATEGORY == "Shotgun") then
                                cfg.BULLET_AMOUNT = 50
                                cfg.TR_DIFF = 0
                            end
                        end)
                    end
                    if Config.Weapon_MaxDamage then
                        pcall(function() cfg.DAMAGE = 999 end)
                        pcall(function() if cfg.GUN then cfg.GUN.DAMAGE = 999 end end)
                    end
                    if Config.Weapon_NoMeleeCooldown then
                        pcall(function()
                            if cfg.CATEGORY == "Melee" or (cfg.GUN and cfg.GUN.CATEGORY == "Melee") then
                                cfg.REST_TIME = 0
                            end
                        end)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- [v10.56] AntiFling：限制RootPart的AssemblyLinearVelocity/AngularVelocity上限
task.spawn(function()
    while true do
        if Config.AntiFling_Enabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local lin = root.AssemblyLinearVelocity
                        if lin and lin.Magnitude > 200 then
                            root.AssemblyLinearVelocity = lin.Unit * 200
                        end
                        local ang = root.AssemblyAngularVelocity
                        if ang and ang.Magnitude > 80 then
                            root.AssemblyAngularVelocity = ang.Unit * 80
                        end
                    end
                end
            end)
            task.wait(0.05)
        else
            task.wait(0.5)
        end
    end
end)

-- [v10.56] AntiCrashRagdoll：禁用车辆碰撞/站立车上/碾压触发的Ragdoll（GameRules阈值=99999）
task.spawn(function()
    while true do
        if Config.AntiCrashRagdoll_Enabled then
            pcall(function()
                local G = GetGameRulesTable()
                if G then
                    pcall(function() G.vehicleCrashSpeedMph = 99999 end)
                    pcall(function() G.vehicleCrashStallsSpeedMph = 99999 end)
                    pcall(function() G.vehicleCrashMotorcycleFallImpactMph = 99999 end)
                    pcall(function() G.vehicleCrashMotorcycleFallMph = 99999 end)
                    pcall(function() G.vehicleCrashMotorcycleFallBelowMaxSpeedMph = 99999 end)
                    pcall(function() G.vehicleCrashNoSeatbeltFallMph = 99999 end)
                    pcall(function() G.vehicleRunOverSpeedMph = 99999 end)
                    pcall(function() G.standingOnMovingVehicleSpeedRagdollMph = 99999 end)
                end
            end)
            task.wait(2)
        else
            task.wait(1)
        end
    end
end)

-- [v10.56] FastRespawn：快速复活（GameRules.respawnTime/deadTime = 0）
task.spawn(function()
    while true do
        if Config.FastRespawn_Enabled then
            pcall(function()
                local G = GetGameRulesTable()
                if G then
                    pcall(function()
                        if type(G.respawnTime) == "table" then
                            G.respawnTime.default = 0
                            G.respawnTime.combatMode = 0
                            G.respawnTime.wanted = 0
                        else
                            G.respawnTime = 0
                        end
                    end)
                    pcall(function() G.deadTime = 0 end)
                    pcall(function() G.deadTimeNoParamedic = 0 end)
                end
            end)
            task.wait(2)
        else
            task.wait(1)
        end
    end
end)

-- [v10.56] NoSunRays：禁用太阳光晕（移除/禁用Lighting中的SunRaysEffect）
task.spawn(function()
    while true do
        if Config.NoSunRays_Enabled then
            pcall(function()
                local sr = Lighting:FindFirstChildWhichIsA("SunRaysEffect")
                if sr then
                    if sr:IsA("PostEffect") or sr:IsA("SunRaysEffect") then
                        sr.Enabled = false
                    end
                end
                -- 同时禁用BloomEffect防止过曝
                local bloom = Lighting:FindFirstChildWhichIsA("BloomEffect")
                if bloom then bloom.Intensity = math.min(bloom.Intensity, 0.3) end
            end)
            task.wait(1)
        else
            task.wait(2)
        end
    end
end)

-- [v10.56] InstantInteract：秒互动（ProximityPrompt.HoldDuration = 0）
task.spawn(function()
    while true do
        if Config.InstantInteract_Enabled then
            pcall(function()
                -- 扫描workspace下所有ProximityPrompt并强制HoldDuration=0
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.HoldDuration ~= 0 then
                        obj.HoldDuration = 0
                    end
                end
            end)
            task.wait(1)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.57新增功能实现 - 服务器端通信版本]
-- 基于 RemoteEvent(PlayerEvent) / RemoteFunction(PlayerFunc) 的反编译分析
-- 包含：FireServer hook 拦截 + 主动调用循环
-- ==========================================

-- 获取 PlayerEvent / PlayerFunc 远程对象
local PlayerEvent = nil
local PlayerFunc = nil
local UnreliableEvent = nil  -- [v10.63新增] 用于 AntiCharRot 拦截
do
    pcall(function()
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 5)
        if remote then
            PlayerEvent = remote:WaitForChild("PlayerEvent", 5)
            PlayerFunc = remote:WaitForChild("PlayerFunc", 5)
            -- [v10.63] 同时获取 UnreliableEvent（charRot 走这个通道）
            pcall(function() UnreliableEvent = remote:WaitForChild("UnreliableEvent", 3) end)
        end
    end)
end

-- ==========================================
-- Hook PlayerEvent.FireServer + PlayerFunc.InvokeServer 拦截
-- 使用 hookmetamethod(__namecall) 拦截所有 FireServer/InvokeServer 调用
-- 拦截规则：
--   GodMode (FireServer):    屏蔽 "takeDamage" / "runOverVictim"
--   ItemGodmode (双通道):     屏蔽所有物品消耗/损耗
--     FireServer:  degradeItem / modifyInventory(change>0) / medicine / throwPhysicsObject / makeSnowball / campfire
--     InvokeServer: fishingBait / catchFish / medicKit / repairKit / fuelCan / refuel /
--                    deployParachute / useLifebuoy / spikeStrips / placeScene / placeItem /
--                    cashDrop / removeGraffiti / trafficPaddle / expandLadder / stretcher /
--                    shootingRange / miniGolf / housingEdit(modifyAsset,purchase=true) /
--                    arrestClient(searchPlayerConfiscateItems)
--   AntiCheatReportHook (FireServer): 屏蔽 "14" / "46" / "772" / "121" / "429" / "violation"
-- [v10.58b] 懒加载：仅当任意上述开关=true 时才安装 Hook
-- [v10.58c] ItemGodmode 增加 modifyInventory 拦截
-- [v10.59] 关键修复：扩展 Hook 到 InvokeServer 通道
--          原因：12+ 物品消耗走 InvokeServer（medicKit/repairKit/fuelCan/fishingBait 等）
--          之前完全没拦截，导致 ItemGodmode 失效
-- ==========================================
local HookInstalled = false
local function InstallPlayerEventHook()
    if HookInstalled then return end
    if not PlayerEvent then return end
    -- 懒加载：仅当任意屏蔽开关启用时才安装 Hook
    -- [v10.63] 扩展触发条件：新增 14 个反作弊拦截开关
    if not (Config.GodMode_Enabled or Config.ItemGodmode_Enabled or Config.AntiCheatReportHook_Enabled
            or Config.AntiHandcuff_Enabled or Config.AntiSit_Enabled or Config.AntiCharRot_Enabled
            or Config.AntiFocusCamera_Enabled or Config.AntiStalkPlayer_Enabled
            or Config.AntiCharPivotTo_Enabled or Config.AntiCharCheckpoint_Enabled
            or Config.AntiGetRidOfSitting_Enabled or Config.AntiFreezeIdle_Enabled
            or Config.AntiPlayEmote_Enabled or Config.AntiRagdollEnhanced_Enabled
            or Config.AntiEjectEnhanced_Enabled or Config.AntiTow_Enabled
            or Config.AntiVehicleTheft_Enabled) then
        return
    end

    -- shouldBlock 接收：(method, self, code, args)
    --   method: "FireServer" 或 "InvokeServer"
    --   self: PlayerEvent 或 PlayerFunc 实例
    --   code: 第一个参数（消息代码字符串）
    --   args: 完整参数表 { code, payload1, payload2, ... }
    local shouldBlock = function(method, self, code, args)
        if type(code) ~= "string" then return false end

        local isFireServer = (method == "FireServer" and self == PlayerEvent)
        local isInvokeServer = (method == "InvokeServer" and self == PlayerFunc)
        if not isFireServer and not isInvokeServer then return false end

        -- GodMode (仅 FireServer)：屏蔽所有伤害类调用
        if isFireServer and Config.GodMode_Enabled and (code == "takeDamage" or code == "runOverVictim") then
            return true
        end

        -- ItemGodmode：屏蔽物品消耗/损耗
        if Config.ItemGodmode_Enabled then
            -- === FireServer 通道的消耗 ===
            if isFireServer then
                -- 1. 工具/武器耐久损耗
                if code == "degradeItem" then return true end
                -- 2. 医疗包消耗（FireServer("medicine")）
                if code == "medicine" then return true end
                -- 3. 投掷物理物品（雪球/手雷等）
                if code == "throwPhysicsObject" then return true end
                -- 4. 制作雪球（消耗雪资源）
                if code == "makeSnowball" then return true end
                -- 5. 篝火互动（消耗木材/燃料）
                if code == "campfire" then return true end
                -- 6. modifyInventory 物品消耗（change > 0 表示移除）
                if code == "modifyInventory" and args and args[2] then
                    local change = args[2].change
                    if type(change) == "number" and change > 0 then return true end
                    if change == "remove" or change == "consume" then return true end
                end
            end

            -- === InvokeServer 通道的消耗（v10.59 新增）===
            if isInvokeServer then
                -- 钓鱼相关
                if code == "fishingBait" then return true end    -- 钓鱼饵消耗
                if code == "catchFish" then return true end      -- 钓到鱼（可能消耗鱼饵）

                -- 医疗/维修/加油
                if code == "medicKit" then return true end       -- 医疗包
                if code == "repairKit" then return true end      -- 修理包
                if code == "fuelCan" then return true end        -- 油桶
                if code == "refuel" then return true end          -- 加油

                -- 工具/装备消耗
                if code == "deployParachute" then return true end  -- 降落伞
                if code == "useLifebuoy" then return true end      -- 救生圈
                if code == "spikeStrips" then return true end      -- 路障钉带
                if code == "expandLadder" then return true end     -- 消防梯
                if code == "stretcher" then return true end        -- 担架
                if code == "trafficPaddle" then return true end    -- 交通指挥棒
                if code == "removeGraffiti" then return true end   -- 清除涂鸦（消耗清洁剂）

                -- 放置/丢弃
                if code == "placeScene" then return true end       -- 放置RP场景物品
                if code == "placeItem" then return true end        -- 放置家具/物品
                if code == "cashDrop" then return true end        -- 丢现金

                -- 娱乐/训练
                if code == "shootingRange" then return true end   -- 射击场（消耗弹药）
                if code == "miniGolf" then return true end        -- 迷你高尔夫

                -- 复合调用（带子命令）
                -- housingEdit/modifyAsset 带 purchase=true 时消耗钱
                if code == "housingEdit" and args and args[2] == "modifyAsset" then
                    if args[3] and type(args[3]) == "table" and args[3].purchase == true then
                        return true
                    end
                end
                -- arrestClient/searchPlayerConfiscateItems 没收物品
                if code == "arrestClient" and args and args[2] == "searchPlayerConfiscateItems" then
                    return true
                end
            end
        end

        -- AntiCheatReportHook (仅 FireServer)：屏蔽反作弊自报告
        if isFireServer and Config.AntiCheatReportHook_Enabled and (
            code == "14" or code == "46" or code == "772"
            or code == "121" or code == "429" or code == "violation"
        ) then
            return true
        end

        -- ======== [v10.63新增] 圣奥里反作弊封禁拦截 ========
        -- 这些是游戏服务端通过 OnClientEvent 通知客户端执行的"强制动作"
        -- 客户端再通过 FireServer/InvokeServer 把动作发回去
        -- 我们拦截客户端发回的请求，让动作不生效

        -- 防被铐：拦截 handcuff / handcuffsOpener InvokeServer
        if isInvokeServer and Config.AntiHandcuff_Enabled
            and (code == "handcuff" or code == "handcuffsOpener" or code == "handcuffsOpenerInitiate") then
            return true
        end

        -- 防强制坐下：拦截 sit InvokeServer
        if isInvokeServer and Config.AntiSit_Enabled and code == "sit" then
            return true
        end

        -- 防强制转向：拦截 charRot / charRotType FireServer
        if isFireServer and Config.AntiCharRot_Enabled
            and (code == "charRot" or code == "charRotType") then
            return true
        end

        -- 防强制凝视：拦截 focusCamera FireServer
        if isFireServer and Config.AntiFocusCamera_Enabled and code == "focusCamera" then
            return true
        end

        -- 防被凝视：拦截 stalkPlayer FireServer
        if isFireServer and Config.AntiStalkPlayer_Enabled and code == "stalkPlayer" then
            return true
        end

        -- 防强制传送：拦截 charPivotTo FireServer
        if isFireServer and Config.AntiCharPivotTo_Enabled and code == "charPivotTo" then
            return true
        end

        -- 防检查点传送：拦截 charCheckpoint FireServer
        if isFireServer and Config.AntiCharCheckpoint_Enabled and code == "charCheckpoint" then
            return true
        end

        -- 防被踢下座位：拦截 getRidOfPlayerSittingOnYou FireServer
        if isFireServer and Config.AntiGetRidOfSitting_Enabled and code == "getRidOfPlayerSittingOnYou" then
            return true
        end

        -- 防强制空闲动画：拦截 freezeIdleAnimation FireServer
        if isFireServer and Config.AntiFreezeIdle_Enabled and code == "freezeIdleAnimation" then
            return true
        end

        -- 防强制表情：拦截 playEmote FireServer
        if isFireServer and Config.AntiPlayEmote_Enabled and code == "playEmote" then
            return true
        end

        -- 防强制Ragdoll：拦截 ragdoll FireServer
        if isFireServer and Config.AntiRagdollEnhanced_Enabled and code == "ragdoll" then
            return true
        end

        -- 防被弹下车：拦截 eject FireServer
        -- 注意：游戏中 eject 是 vehicle 子命令 FireServer("vehicle", "eject", ...)
        if isFireServer and Config.AntiEjectEnhanced_Enabled
            and code == "vehicle" and args and args[2] == "eject" then
            return true
        end
        -- 也拦截 kickPassenger
        if isFireServer and Config.AntiEjectEnhanced_Enabled
            and code == "vehicle" and args and args[2] == "kickPassenger" then
            return true
        end

        -- 防车辆被拖：拦截 towing / towStolen InvokeServer
        if isInvokeServer and Config.AntiTow_Enabled
            and (code == "towing" or code == "towStolen") then
            return true
        end

        -- 防车辆被偷：拦截 stealVehicle InvokeServer
        if isInvokeServer and Config.AntiVehicleTheft_Enabled and code == "stealVehicle" then
            return true
        end

        return false
    end

    -- 优先尝试 hookmetamethod（同时拦截 FireServer 和 InvokeServer）
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            -- 同时支持 FireServer (PlayerEvent) 和 InvokeServer (PlayerFunc)
            -- [v10.63] 同时支持 UnreliableEvent:FireServer("charRot",...) 用于 AntiCharRot
            if (method == "FireServer" and (self == PlayerEvent or self == UnreliableEvent)) or
               (method == "InvokeServer" and self == PlayerFunc) then
                local args = { ... }
                if shouldBlock(method, self, args[1], args) then
                    return  -- 静默屏蔽（InvokeServer 会返回 nil）
                end
            end
            return oldNamecall(self, ...)
        end)
        HookInstalled = true
    end)

    -- 后备：尝试 hookfunction（部分执行器支持）
    if not HookInstalled then
        pcall(function()
            local oldFire = PlayerEvent.FireServer
            hookfunction(oldFire, function(self, code, ...)
                local args = { code, ... }
                if shouldBlock("FireServer", self, code, args) then return end
                return oldFire(self, code, ...)
            end)
            if PlayerFunc then
                local oldInvoke = PlayerFunc.InvokeServer
                hookfunction(oldInvoke, function(self, code, ...)
                    local args = { code, ... }
                    if shouldBlock("InvokeServer", self, code, args) then return nil end
                    return oldInvoke(self, code, ...)
                end)
            end
            HookInstalled = true
        end)
    end

    -- 状态打印
    if HookInstalled then
        if Config.DebugMode_Enabled then
            local channels = {}
            if Config.GodMode_Enabled then table.insert(channels, "GodMode") end
            if Config.ItemGodmode_Enabled then table.insert(channels, "ItemGodmode") end
            if Config.AntiCheatReportHook_Enabled then table.insert(channels, "AntiCheatReport") end
            -- [v10.63] 新增反作弊通道
            if Config.AntiHandcuff_Enabled then table.insert(channels, "AntiHandcuff") end
            if Config.AntiSit_Enabled then table.insert(channels, "AntiSit") end
            if Config.AntiCharRot_Enabled then table.insert(channels, "AntiCharRot") end
            if Config.AntiFocusCamera_Enabled then table.insert(channels, "AntiFocusCamera") end
            if Config.AntiStalkPlayer_Enabled then table.insert(channels, "AntiStalkPlayer") end
            if Config.AntiCharPivotTo_Enabled then table.insert(channels, "AntiCharPivotTo") end
            if Config.AntiCharCheckpoint_Enabled then table.insert(channels, "AntiCharCheckpoint") end
            if Config.AntiGetRidOfSitting_Enabled then table.insert(channels, "AntiGetRidOfSitting") end
            if Config.AntiFreezeIdle_Enabled then table.insert(channels, "AntiFreezeIdle") end
            if Config.AntiPlayEmote_Enabled then table.insert(channels, "AntiPlayEmote") end
            if Config.AntiRagdollEnhanced_Enabled then table.insert(channels, "AntiRagdollEnhanced") end
            if Config.AntiEjectEnhanced_Enabled then table.insert(channels, "AntiEjectEnhanced") end
            if Config.AntiTow_Enabled then table.insert(channels, "AntiTow") end
            if Config.AntiVehicleTheft_Enabled then table.insert(channels, "AntiVehicleTheft") end
            print("[KillSystem] Hook 已安装 通道: " .. table.concat(channels, ", "))
        end
    else
        if Config.DebugMode_Enabled then
            print("[KillSystem] 警告: 无法安装 Hook（执行器不支持 hookmetamethod/hookfunction）")
        end
    end
end

-- 立即尝试安装一次（如果默认开关已开启）
InstallPlayerEventHook()

-- ==========================================
-- [v10.63新增] AntiClientKick: Hook Player:Kick() 防止客户端被踢
-- 部分游戏服务端会通过 LocalPlayer:Kick() 把客户端踢出
-- 这里 Hook 后拦截所有 Kick 调用
-- ==========================================
local KickHookInstalled = false
local function InstallAntiClientKickHook()
    if KickHookInstalled then return end
    if not Config.AntiClientKick_Enabled then return end

    pcall(function()
        local oldKick = LocalPlayer.Kick
        hookfunction(oldKick, function(self, reason)
            if Config.AntiClientKick_Enabled and self == LocalPlayer then
                if Config.DebugMode_Enabled then
                    print("[KillSystem] 拦截 Kick 调用: " .. tostring(reason))
                end
                if ScreenLog then ScreenLog("拦截被踢: " .. tostring(reason)) end
                return  -- 静默拒绝
            end
            return oldKick(self, reason)
        end)
        KickHookInstalled = true
        if Config.DebugMode_Enabled then
            print("[KillSystem] AntiClientKick Hook 已安装")
        end
    end)

    -- 后备：hookmetamethod __namecall
    if not KickHookInstalled then
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if Config.AntiClientKick_Enabled and method == "Kick" and self == LocalPlayer then
                    local args = { ... }
                    if Config.DebugMode_Enabled then
                        print("[KillSystem] 拦截 Kick(namecall): " .. tostring(args[1]))
                    end
                    if ScreenLog then ScreenLog("拦截被踢(namecall): " .. tostring(args[1])) end
                    return  -- 静默拒绝
                end
                return oldNamecall(self, ...)
            end)
            KickHookInstalled = true
        end)
    end
end

task.spawn(function()
    task.wait(3)
    while true do
        if Config.AntiClientKick_Enabled and not KickHookInstalled then
            InstallAntiClientKickHook()
        end
        task.wait(2)
    end
end)

-- ==========================================
-- [v10.63新增] 暴力功能：群体攻击附近玩家/车辆
-- 基于 FireServer/InvokeServer 协议主动调用
-- ==========================================

-- 辅助函数：获取附近所有玩家（除自己）
local function GetNearbyPlayers(range)
    local result = {}
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return result end
    local localPos = localChar.HumanoidRootPart.Position
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - localPos).Magnitude
            if dist <= range then
                table.insert(result, { player = player, char = player.Character, dist = dist })
            end
        end
    end
    return result
end

-- 辅助函数：获取附近所有车辆
local function GetNearbyVehicles(range)
    local result = {}
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return result end
    local localPos = localChar.HumanoidRootPart.Position
    local vehiclesFolder = workspace:FindFirstChild("Gameplay")
        and workspace.Gameplay:FindFirstChild("Vehicles")
    if not vehiclesFolder then return result end
    for _, car in ipairs(vehiclesFolder:GetChildren()) do
        if car:IsA("Model") and car.PrimaryPart then
            local dist = (car.PrimaryPart.Position - localPos).Magnitude
            if dist <= range then
                table.insert(result, { car = car, dist = dist })
            end
        end
    end
    return result
end

-- [暴力] MassHandcuff: 给附近所有玩家发 handcuff
task.spawn(function()
    task.wait(3)
    while true do
        if Config.MassHandcuff_Enabled and PlayerFunc then
            pcall(function()
                local nearby = GetNearbyPlayers(Config.MassHandcuff_Range)
                for _, info in ipairs(nearby) do
                    pcall(function()
                        -- PlayerFunc:InvokeServer("handcuff", targetPlayer, false)
                        PlayerFunc:InvokeServer("handcuff", info.player, false)
                    end)
                end
            end)
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- [暴力] MassArrest: 给附近所有玩家发 arrestClient 没收物品
task.spawn(function()
    task.wait(3)
    while true do
        if Config.MassArrest_Enabled and PlayerFunc then
            pcall(function()
                local nearby = GetNearbyPlayers(Config.MassArrest_Range)
                for _, info in ipairs(nearby) do
                    pcall(function()
                        -- PlayerFunc:InvokeServer("arrestClient", "searchPlayerConfiscateItems", { player=... })
                        PlayerFunc:InvokeServer("arrestClient", "searchPlayerConfiscateItems", {
                            player = info.player
                        })
                    end)
                end
            end)
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- [暴力] MassRagdoll: 给附近所有玩家发 ragdoll
task.spawn(function()
    task.wait(3)
    while true do
        if Config.MassRagdoll_Enabled and PlayerEvent then
            pcall(function()
                local nearby = GetNearbyPlayers(Config.MassRagdoll_Range)
                for _, info in ipairs(nearby) do
                    pcall(function()
                        -- PlayerEvent:FireServer("ragdoll", target, type)
                        -- target 为 Player 实例，type 可为 1（普通倒地）
                        PlayerEvent:FireServer("ragdoll", info.player, 1)
                    end)
                end
            end)
            task.wait(0.3)
        else
            task.wait(2)
        end
    end
end)

-- [暴力] MassEject: 把附近所有车里的玩家 eject 出来
task.spawn(function()
    task.wait(3)
    while true do
        if Config.MassEject_Enabled and PlayerEvent then
            pcall(function()
                local nearby = GetNearbyVehicles(Config.MassEject_Range)
                for _, info in ipairs(nearby) do
                    pcall(function()
                        -- PlayerEvent:FireServer("vehicle", "kickPassenger", car)
                        PlayerEvent:FireServer("vehicle", "kickPassenger", info.car)
                    end)
                end
            end)
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- [暴力] MassStun: 组合拳 ragdoll + eject + sit 给附近所有玩家
task.spawn(function()
    task.wait(3)
    while true do
        if Config.MassStun_Enabled and PlayerEvent then
            pcall(function()
                local nearby = GetNearbyPlayers(Config.MassStun_Range)
                for _, info in ipairs(nearby) do
                    pcall(function()
                        -- 三连击：倒地 + 弹出 + 强制坐下
                        PlayerEvent:FireServer("ragdoll", info.player, 1)
                    end)
                    pcall(function()
                        PlayerEvent:FireServer("sit", info.player)
                    end)
                end
                -- 同时给附近车辆弹乘客
                local nearbyVehicles = GetNearbyVehicles(Config.MassStun_Range)
                for _, info in ipairs(nearbyVehicles) do
                    pcall(function()
                        PlayerEvent:FireServer("vehicle", "kickPassenger", info.car)
                    end)
                end
            end)
            task.wait(0.3)
        else
            task.wait(2)
        end
    end
end)

-- [暴力] VehicleDestroySpam: 给附近所有车辆发 vehicle:damage:100
task.spawn(function()
    task.wait(3)
    while true do
        if Config.VehicleDestroySpam_Enabled and PlayerEvent then
            pcall(function()
                local nearby = GetNearbyVehicles(Config.VehicleDestroySpam_Range)
                for _, info in ipairs(nearby) do
                    pcall(function()
                        -- PlayerEvent:FireServer("vehicle", "damage", 100)
                        PlayerEvent:FireServer("vehicle", "damage", 100, info.car)
                    end)
                end
            end)
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- [暴力] VehicleStopAll: 给附近所有车发 vehicle:stop
task.spawn(function()
    task.wait(3)
    while true do
        if Config.VehicleStopAll_Enabled and PlayerEvent then
            pcall(function()
                local nearby = GetNearbyVehicles(Config.VehicleStopAll_Range)
                for _, info in ipairs(nearby) do
                    pcall(function()
                        -- PlayerEvent:FireServer("vehicle", "stop")
                        PlayerEvent:FireServer("vehicle", "stop", info.car)
                    end)
                end
            end)
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- [暴力] VehicleLockAll: 强制锁车 vehicle:lock=true
task.spawn(function()
    task.wait(3)
    while true do
        if Config.VehicleLockAll_Enabled and PlayerEvent then
            pcall(function()
                local nearby = GetNearbyVehicles(Config.VehicleLockAll_Range)
                for _, info in ipairs(nearby) do
                    pcall(function()
                        -- PlayerEvent:FireServer("vehicle", "lock", true)
                        PlayerEvent:FireServer("vehicle", "lock", true, info.car)
                    end)
                end
            end)
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- [暴力] BulletStorm: 每帧向最近玩家发 50 发 bullet（弹幕风暴）
task.spawn(function()
    task.wait(3)
    while true do
        if Config.BulletStorm_Enabled and PlayerEvent then
            pcall(function()
                local nearby = GetNearbyPlayers(Config.BulletStorm_Range)
                if #nearby > 0 then
                    -- 选最近玩家
                    table.sort(nearby, function(a, b) return a.dist < b.dist end)
                    local target = nearby[1]
                    if target.char and target.char:FindFirstChild("Head") then
                        local head = target.char.Head
                        -- 每帧发 50 发子弹
                        for i = 1, 50 do
                            pcall(function()
                                -- PlayerEvent:FireServer("bullet", { ... })
                                PlayerEvent:FireServer("bullet", {
                                    pos = head.Position,
                                    target = target.player,
                                    damageFactor = 2.0,
                                    bulletProofTool = false,
                                })
                            end)
                        end
                        -- 同时发 damage 包
                        for i = 1, 5 do
                            pcall(function()
                                PlayerEvent:FireServer("damage", {
                                    bodyParts = { { head, 1 } },
                                    shotCode = math.random(1, 99999),
                                    pos = head.Position,
                                    target = target.player,
                                    damageFactor = 2.0,
                                    bulletProofTool = false,
                                })
                            end)
                        end
                    end
                end
            end)
            task.wait(0.1)  -- 每 100ms 一轮（约 500 发/秒）
        else
            task.wait(2)
        end
    end
end)

-- [暴力] ForceFling: 给附近所有玩家发 applyImpulse（强制击飞）
-- 注意：applyImpulse 走 OnClientEvent 通道，需要 Hook 拦截来发送
-- 这里使用直接的 LocalPlayer 速度修改 + 给目标玩家的 HRP 设置高速度
task.spawn(function()
    task.wait(3)
    while true do
        if Config.ForceFling_Enabled then
            pcall(function()
                local nearby = GetNearbyPlayers(Config.ForceFling_Range)
                for _, info in ipairs(nearby) do
                    pcall(function()
                        -- 尝试直接给目标 HRP 设置 AssemblyLinearVelocity（仅对本地有网络所有权的玩家有效）
                        if info.char and info.char:FindFirstChild("HumanoidRootPart") then
                            local root = info.char.HumanoidRootPart
                            -- 检查是否本地拥有网络所有权
                            if root:IsA("BasePart") and root:CanSetNetworkOwnership() then
                                root.AssemblyLinearVelocity = Vector3.new(
                                    math.random(-200, 200),
                                    math.random(200, 500),
                                    math.random(-200, 200)
                                )
                            end
                        end
                        -- 同时通过 FireServer("vehicle", "PITmaneuver", target, 1) 让车辆也击飞
                        if PlayerEvent and info.char:FindFirstChildOfClass("Humanoid") then
                            pcall(function()
                                PlayerEvent:FireServer("damage", {
                                    bodyParts = { { info.char:FindFirstChild("HumanoidRootPart"), 1 } },
                                    shotCode = math.random(1, 99999),
                                    pos = info.char.HumanoidRootPart.Position,
                                    target = info.player,
                                    damageFactor = 0.1,  -- 低伤害但高击退
                                    bulletProofTool = false,
                                })
                            end)
                        end
                    end)
                end
            end)
            task.wait(0.3)
        else
            task.wait(2)
        end
    end
end)

-- 监听器循环：当用户在菜单中开启任意屏蔽开关时再尝试安装
task.spawn(function()
    task.wait(2)  -- 等游戏初始化
    while true do
        if not HookInstalled and (
            Config.GodMode_Enabled or Config.ItemGodmode_Enabled or Config.AntiCheatReportHook_Enabled
            or Config.AntiHandcuff_Enabled or Config.AntiSit_Enabled or Config.AntiCharRot_Enabled
            or Config.AntiFocusCamera_Enabled or Config.AntiStalkPlayer_Enabled
            or Config.AntiCharPivotTo_Enabled or Config.AntiCharCheckpoint_Enabled
            or Config.AntiGetRidOfSitting_Enabled or Config.AntiFreezeIdle_Enabled
            or Config.AntiPlayEmote_Enabled or Config.AntiRagdollEnhanced_Enabled
            or Config.AntiEjectEnhanced_Enabled or Config.AntiTow_Enabled
            or Config.AntiVehicleTheft_Enabled
        ) then
            -- 重新获取 PlayerFunc（之前可能未加载）
            if not PlayerFunc then
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
                    if remote then
                        PlayerFunc = remote:FindFirstChild("PlayerFunc")
                    end
                end)
            end
            -- [v10.63] 同时获取 UnreliableEvent（用于 AntiCharRot）
            if not UnreliableEvent then
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
                    if remote then
                        UnreliableEvent = remote:FindFirstChild("UnreliableEvent")
                    end
                end)
            end
            InstallPlayerEventHook()
        end
        task.wait(1)
    end
end)

-- ==========================================
-- [v10.57] AntiPullOver: 循环通知服务器"不可被警方拦下"
-- PlayerEvent:FireServer("vehicle", "policeCanPullOverPlayer", false)
-- ==========================================
task.spawn(function()
    while true do
        if Config.AntiPullOver_Enabled and PlayerEvent then
            pcall(function()
                PlayerEvent:FireServer("vehicle", "policeCanPullOverPlayer", false)
            end)
            task.wait(5)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.57] FreeTools: 自动装备特殊工具（MDT/Phone/Map/SmartRadio等）
-- PlayerFunc:InvokeServer("equipSpecialItem", name, true)
-- ==========================================
local FREE_TOOLS_LIST = {
    "Phone", "Map", "MDT", "Smart Radio",
    "Phone Camera Front", "Phone Camera Rear",
    "EmoteTool", "Newspaper",
}
task.spawn(function()
    while true do
        if Config.FreeTools_Enabled and PlayerFunc then
            for _, toolName in ipairs(FREE_TOOLS_LIST) do
                pcall(function()
                    PlayerFunc:InvokeServer("equipSpecialItem", toolName, true)
                end)
                task.wait(0.1)
            end
            task.wait(15)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.57] CatchFishSpam: 自动钓鱼刷钱
-- PlayerFunc:InvokeServer("catchFish")
-- ==========================================
task.spawn(function()
    while true do
        if Config.CatchFishSpam_Enabled and PlayerFunc then
            pcall(function()
                PlayerFunc:InvokeServer("catchFish")
            end)
            task.wait(0.3)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.57] FreeHealSpam: 自动医疗包治疗（无限回血）
-- PlayerEvent:FireServer("medicine")
-- ==========================================
task.spawn(function()
    while true do
        if Config.FreeHealSpam_Enabled and PlayerEvent then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.Health < hum.MaxHealth then
                pcall(function()
                    PlayerEvent:FireServer("medicine")
                end)
            end
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.57] ServerClickTeleport: 服务器端点击传送（绕过客户端传送检测）
-- PlayerEvent:FireServer("charPivotTo", CFrame, instance, id, flag)
-- 监听鼠标右键+Shift按下时执行
-- ==========================================
task.spawn(function()
    local teleporting = false
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not Config.ServerClickTeleport_Enabled then return end
        if not PlayerEvent then return end
        -- 触发键：Shift + 右键
        if input.KeyCode == Enum.KeyCode.Backspace or
           (input.KeyCode == Enum.KeyCode.Q and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)) then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local camera = workspace.CurrentCamera
            if not root or not camera then return end

            -- 计算鼠标指向位置
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { char }
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
            if not result then return end

            local targetCF = CFrame.new(result.Position + Vector3.new(0, 3, 0))
            local pivotId = LocalPlayer:GetAttribute("CharPivotToId") or 0
            pcall(function()
                PlayerEvent:FireServer("charPivotTo", targetCF, root, pivotId, true)
            end)
        end
    end)
end)

-- ==========================================
-- [v10.57] StalkNearestPlayer: 按键凝视最近玩家（服务器端 stalk）
-- PlayerEvent:FireServer("stalkPlayer", targetCharacter)
-- 触发键：F6
-- ==========================================
task.spawn(function()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not Config.StalkNearestPlayer_Enabled then return end
        if not PlayerEvent then return end
        if input.KeyCode ~= Enum.KeyCode.F6 then return end

        local localChar = LocalPlayer.Character
        if not localChar then return end
        local localRoot = localChar:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end

        -- 查找最近的玩家
        local nearestChar = nil
        local nearestDist = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local dist = (targetRoot.Position - localRoot.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestChar = player.Character
                    end
                end
            end
        end

        if nearestChar then
            pcall(function()
                PlayerEvent:FireServer("stalkPlayer", nearestChar)
            end)
        end
    end)
end)

-- ==========================================
-- [v10.58新增功能实现 - 无限体力/饥饿 + 暴力枪械扩展]
-- 基于 v10.42 反编译版 + 反编译分析扩展
-- ==========================================

-- 共用：获取 Framework.Core 模块（v10.57 已存在 GetFrameworkCore，此处复用）
-- 共用：PlayerEvent 已在 v10.57 server_features.lua 中定义为全局变量

-- ==========================================
-- [v10.58] 无限体力/饥饿（服务器端高频发包 setStaminaOrFood）
-- v10.42 已验证可用：高频发包压倒服务端的衰减逻辑
-- ==========================================
task.spawn(function()
    while true do
        if (Config.ForceStamina_Enabled or Config.ForceFood_Enabled) and PlayerEvent then
            if Config.ForceStamina_Enabled then
                pcall(function()
                    PlayerEvent:FireServer("setStaminaOrFood", "stamina", 100)
                end)
            end
            if Config.ForceFood_Enabled then
                pcall(function()
                    PlayerEvent:FireServer("setStaminaOrFood", "food", 100)
                end)
            end
            task.wait(0.1)  -- 高频发包每0.1秒
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- [v10.58] 暴力枪械扩展 1：Weapon_BulletAmount
-- 修改武器Config.BULLET_AMOUNT，让任何枪都像散弹一样多发
-- 同时配合 Ranged_MultiBullet (客户端模拟多发)，效果叠加
-- ==========================================
task.spawn(function()
    while true do
        if Config.Weapon_BulletAmount_Enabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local cfgModule = tool:FindFirstChild("Config")
                            if cfgModule then
                                local ok, cfg = pcall(require, cfgModule)
                                if ok and cfg and type(cfg) == "table" then
                                    pcall(function() cfg.BULLET_AMOUNT = Config.Weapon_BulletAmount_Value end)
                                    pcall(function() if cfg.GUN then cfg.GUN.BULLET_AMOUNT = Config.Weapon_BulletAmount_Value end end)
                                    -- 散弹扩散设为0，多发全中同一目标
                                    pcall(function() cfg.TR_DIFF = 0 end)
                                    pcall(function() if cfg.GUN then cfg.GUN.TR_DIFF = 0 end end)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- [v10.58] 暴力枪械扩展 2：Weapon_NoSpread / Weapon_InfiniteRange
-- - NoSpread：将所有散射参数置0
-- - InfiniteRange：将武器Config.MAX_DISTANCE = 99999
-- ==========================================
task.spawn(function()
    while true do
        if Config.Weapon_NoSpread_Enabled or Config.Weapon_InfiniteRange_Enabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local cfgModule = tool:FindFirstChild("Config")
                            if cfgModule then
                                local ok, cfg = pcall(require, cfgModule)
                                if ok and cfg and type(cfg) == "table" then
                                    if Config.Weapon_NoSpread_Enabled then
                                        pcall(function() cfg.TR_DIFF = 0 end)
                                        pcall(function() cfg.SPREAD = 0 end)
                                        pcall(function() cfg.ACCURACY = 0.001 end)
                                        pcall(function() if cfg.GUN then cfg.GUN.TR_DIFF = 0; cfg.GUN.SPREAD = 0 end end)
                                    end
                                    if Config.Weapon_InfiniteRange_Enabled then
                                        pcall(function() cfg.MAX_DISTANCE = 99999 end)
                                        pcall(function() cfg.RANGE = 99999 end)
                                        pcall(function() if cfg.GUN then cfg.GUN.MAX_DISTANCE = 99999 end end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- [v10.58] 暴力枪械扩展 3：Weapon_AutoReload
-- 主动循环：当弹夹为空时自动调用 Reload（无需玩家按R）
-- 通过 require(Config).GUN.CURRENT_AMMO 检测弹药，主动触发
-- ==========================================
task.spawn(function()
    while true do
        if Config.Weapon_AutoReload_Enabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local cfgModule = tool:FindFirstChild("Config")
                            if cfgModule then
                                local ok, cfg = pcall(require, cfgModule)
                                if ok and cfg and cfg.GUN and cfg.GUN.CURRENT_AMMO == 0 then
                                    -- 模拟按R换弹：触发工具的Reload事件
                                    local reloadEvent = tool:FindFirstChild("Reload", true)
                                    if reloadEvent and reloadEvent:IsA("RemoteEvent") then
                                        pcall(function() reloadEvent:FireServer() end)
                                    elseif reloadEvent and reloadEvent:IsA("BindableEvent") then
                                        pcall(function() reloadEvent:Fire() end)
                                    end
                                    -- 主动恢复弹药到最大值
                                    pcall(function()
                                        cfg.GUN.CURRENT_AMMO = cfg.GUN.MAGAZINE_SIZE or 30
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.3)
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- [v10.58] 暴力枪械扩展 4：SilentAim（子弹追踪 Hook）
-- Hook PlayerEvent.FireServer，当 cmd == "bullet" 时自动修正命中位置为最近敌人头部
-- 这是 v10.42 中验证可用的暴力实现，比 v10.53 的纯相机操控更彻底
-- [v10.58b修正] 改为懒加载：仅在 VapeSilentAim_Enabled=true 时才安装 Hook
--              防止脚本启动时无条件 hook 干扰游戏其他 FireServer 调用
-- ==========================================
local SilentAimHookInstalled = false
local function FindNearestTargetToScreenCenter()
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local nearestTarget = nil
    local nearestDist = Config.VapeSilentAim_FOV or 200

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if head then
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestTarget = head.Position
                        end
                    end
                end
            end
        end
    end
    return nearestTarget
end

local function InstallSilentAimHook()
    if SilentAimHookInstalled then return end
    if not PlayerEvent then return end
    if not Config.VapeSilentAim_Enabled then return end  -- 懒加载：仅当开关为true时安装

    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and self == PlayerEvent and Config.VapeSilentAim_Enabled then
                local args = { ... }
                if args[1] == "bullet" and args[2] and args[2].pos then
                    local target = FindNearestTargetToScreenCenter()
                    if target then
                        args[2].pos = target
                        if args[2].posDestroyX then
                            args[2].posDestroyX = target.X
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        SilentAimHookInstalled = true
    end)

    -- 后备：Hook PlayerEvent.FireServer 函数
    if not SilentAimHookInstalled then
        pcall(function()
            local oldFire
            oldFire = hookfunction(PlayerEvent.FireServer, function(self, cmd, ...)
                if Config.VapeSilentAim_Enabled and cmd == "bullet" then
                    local args = { ... }
                    if args[1] and args[1].pos then
                        local target = FindNearestTargetToScreenCenter()
                        if target then
                            args[1].pos = target
                            if args[1].posDestroyX then
                                args[1].posDestroyX = target.X
                            end
                        end
                    end
                    return oldFire(self, cmd, unpack(args))
                end
                return oldFire(self, cmd, ...)
            end)
            SilentAimHookInstalled = true
        end)
    end
end

-- 在 VapeSilentAim 配置变更时检查是否需要安装 Hook
-- 由于菜单切换时会触发 Config.VapeSilentAim_Enabled 状态变化，这里只检查一次
-- 如果用户开启后立即生效，可通过 task.spawn 延迟检查
task.spawn(function()
    task.wait(2)  -- 等游戏初始化完成
    while true do
        if Config.VapeSilentAim_Enabled and not SilentAimHookInstalled then
            InstallSilentAimHook()
        end
        task.wait(1)
    end
end)

-- ==========================================
-- [v10.58] 暴力枪械扩展 5：DamageInjector（注入式伤害）
-- Hook PlayerEvent.FireServer，当 cmd == "damage" 时自动注入：
-- - damageFactor = 999 (最大伤害倍率)
-- - bulletProofTool = false (防弹衣穿透)
-- - bodyParts 自动扩展为头部+躯干（全部命中）
-- [v10.58b修正] 改为懒加载：仅在 DamageInjector_Enabled=true 时才安装 Hook
-- ==========================================
local DamageInjectorHookInstalled = false
local function InstallDamageInjectorHook()
    if DamageInjectorHookInstalled then return end
    if not PlayerEvent then return end
    if not Config.DamageInjector_Enabled then return end  -- 懒加载

    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and self == PlayerEvent and Config.DamageInjector_Enabled then
                local args = { ... }
                if args[1] == "damage" and args[2] then
                    -- 注入最大伤害倍率
                    pcall(function() args[2].damageFactor = 999 end)
                    -- 防弹衣穿透
                    pcall(function() args[2].bulletProofTool = false end)
                    -- 扩展bodyParts为多部位命中
                    pcall(function()
                        args[2].bodyParts = {
                            { "Head", 5 },
                            { "Torso", 5 },
                            { "HumanoidRootPart", 5 },
                            { "Left Arm", 3 },
                            { "Right Arm", 3 },
                            { "Left Leg", 3 },
                            { "Right Leg", 3 },
                        }
                    end)
                end
            end
            return oldNamecall(self, ...)
        end)
        DamageInjectorHookInstalled = true
    end)
end

task.spawn(function()
    task.wait(2)
    while true do
        if Config.DamageInjector_Enabled and not DamageInjectorHookInstalled then
            InstallDamageInjectorHook()
        end
        task.wait(1)
    end
end)

-- ==========================================
-- [v10.58] 暴力枪械扩展 6：TriggerBot（自动扳机）
-- 当鼠标指向敌人时自动开火（点击），无需手动点击
-- 实现：RenderStepped 中检测鼠标射线命中目标，触发 tool:Activate()
-- ==========================================
task.spawn(function()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not Config.TriggerBot_Enabled then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        -- 已被自动开火处理，无需重复
    end)

    -- 主循环：检测鼠标指向目标，模拟点击
    while true do
        if Config.TriggerBot_Enabled then
            pcall(function()
                local camera = workspace.CurrentCamera
                local mousePos = UserInputService:GetMouseLocation()
                if camera then
                    local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances = { LocalPlayer.Character }
                    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
                    if result and result.Instance then
                        -- 检测命中是否属于敌人玩家角色
                        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
                        if hitChar then
                            local hum = hitChar:FindFirstChild("Humanoid")
                            if hum and hum.Health > 0 then
                                -- 确认不是自己
                                local hitPlayer = Players:GetPlayerFromCharacter(hitChar)
                                if hitPlayer and hitPlayer ~= LocalPlayer then
                                    -- 检查好友
                                    if not Config.Aimbot_FriendsCheck or not LocalPlayer:IsFriendsWith(hitPlayer.UserId) then
                                        -- 触发工具Activate
                                        local localChar = LocalPlayer.Character
                                        if localChar then
                                            for _, tool in ipairs(localChar:GetChildren()) do
                                                if tool:IsA("Tool") then
                                                    pcall(function() tool:Activate() end)
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.05)  -- 20Hz
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- [v10.60新增功能实现 - GodMode增强 + 防入狱 + 刷钱]
-- 基于反编译脚本中的 OnClientEvent 事件 + Humanoid API + 属性设置
-- ==========================================

-- ==========================================
-- [v10.60] GodMode 增强 1：BulletProof 属性（免疫枪械伤害）
-- 关键发现：枪械伤害走 FireServer("damage",...) 由攻击者发送
-- 服务端调用 canCombat(shooter, victim) 校验：
--   - victim 有 BulletProof 属性 → canCombat 返回 false → 攻击者无法伤害
-- 设置 BulletProof=true 让攻击者的 canCombat 校验失败
-- ==========================================
task.spawn(function()
    while true do
        if Config.GodModeBulletProof_Enabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    -- BulletProof = true 阻止所有伤害类战斗
                    if not char:GetAttribute("BulletProof") then
                        char:SetAttribute("BulletProof", true)
                    end
                    -- SpawnProtection = true 是更柔和的拒绝（"under spawn protection"）
                    -- 服务端会返回友好提示，不会触发反作弊告警
                    if not char:GetAttribute("SpawnProtection") then
                        char:SetAttribute("SpawnProtection", true)
                    end
                end
            end)
            task.wait(1)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.60] GodMode 增强 2：Humanoid 硬化
-- - 禁用 Dead 状态：防止进入死亡状态
-- - 禁用 Physics 状态：防止进入物理Ragdoll状态
-- - BreakJointsOnDeath = false：防止死亡时关节断裂
-- - HealthChanged 监听：血量低于阈值时强制恢复
-- ==========================================
task.spawn(function()
    while true do
        if Config.GodModeHumanoidHardening_Enabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    local hum = char.Humanoid
                    -- 禁用死亡状态
                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
                    -- 禁用物理状态（防Ragdoll）
                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false) end)
                    -- 防止死亡时关节断裂
                    pcall(function() hum.BreakJointsOnDeath = false end)
                    -- 血量低于30%时强制恢复到满血
                    if hum.Health < hum.MaxHealth * 0.3 then
                        pcall(function() hum.Health = hum.MaxHealth end)
                    end
                    -- 持续提升 MaxHealth 上限
                    if hum.MaxHealth < 9999 then
                        pcall(function() hum.MaxHealth = 9999 end)
                        pcall(function() hum.Health = 9999 end)
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.60] 防入狱 + 防击退：拦截 OnClientEvent 事件
-- 关键发现：服务端通过 OnClientEvent 推送以下事件来强制入狱：
--   - respawnCharacter：服务端命令重生（入狱时传送至监狱）
--   - charPivotTo：服务端命令PivotTo（监狱传送）
--   - sit：服务端命令坐下（强制拘捕坐姿）
--   - redBlueTransition：服务端命令红蓝过渡视觉（警灯/入狱视觉）
--   - characterIsPhysicallyOccupied：服务端禁用装备（拘捕期间）
--   - applyImpulse：服务端命令物理冲击（子弹/爆炸击退）
-- 由于这些是服务端→客户端事件，无法用 FireServer Hook 拦截
-- 我们 Hook OnClientEvent 本身，过滤掉这些事件
-- ==========================================
local OnClientEventHookInstalled = false
local function InstallOnClientEventHook()
    if OnClientEventHookInstalled then return end
    if not PlayerEvent then return end
    -- 懒加载：仅当防入狱或防击退开启时才安装
    if not (Config.AntiArrest_Enabled or Config.AntiKnockback_Enabled) then
        return
    end

    -- 拦截的事件列表
    -- AntiArrest: respawnCharacter / charPivotTo / sit / redBlueTransition / characterIsPhysicallyOccupied
    -- AntiKnockback: applyImpulse
    local blockedEvents = {}
    if Config.AntiArrest_Enabled then
        for _, name in ipairs({
            "respawnCharacter", "charPivotTo", "sit", "redBlueTransition",
            "characterIsPhysicallyOccupied"
        }) do
            blockedEvents[name] = true
        end
    end
    if Config.AntiKnockback_Enabled then
        blockedEvents["applyImpulse"] = true
    end

    -- 由于 OnClientEvent 只能 Connect 一次（多连接会被全部触发）
    -- 我们使用 Signal 包装原 OnClientEvent
    -- 但实际上 Roblox 允许多次 Connect OnClientEvent
    -- 这里直接添加一个监听器，无法阻止原监听器执行
    -- 替代方案：Hook PlayerEvent 模块本身或 game 定义 OnClientEvent
    -- 最实用的方式：监听并立即反向操作
    pcall(function()
        PlayerEvent.OnClientEvent:Connect(function(eventName, ...)
            -- AntiArrest: respawnCharacter 事件 - 反向操作
            -- 监听到服务端命令重生时，立即设置 Arrested=nil 防止入狱
            if Config.AntiArrest_Enabled and eventName == "respawnCharacter" then
                local arrested = LocalPlayer:GetAttribute("Arrested")
                if arrested then
                    pcall(function() LocalPlayer:SetAttribute("Arrested", nil) end)
                    pcall(function() LocalPlayer:SetAttribute("PrepareToSetPrisonSentence", nil) end)
                    if Config.DebugMode_Enabled then
                        print("[防入狱] 拦截 respawnCharacter，已清除 Arrested 属性")
                    end
                end
            end
            -- AntiArrest: charPivotTo 事件 - 记录位置用于反向传送
            if Config.AntiArrest_Enabled and eventName == "charPivotTo" then
                -- 记录最后一次合法位置，等服务端试图传送时立即传送回去
                -- 但这里无法阻止 PivotTo，只能监听
                if Config.DebugMode_Enabled then
                    print("[防入狱] 检测到 charPivotTo 事件（可能是入狱传送）")
                end
            end
            -- AntiArrest: sit 事件 - 立即起身
            if Config.AntiArrest_Enabled and eventName == "sit" then
                task.spawn(function()
                    task.wait(0.1)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        pcall(function()
                            char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end)
                    end
                end)
            end
            -- AntiKnockback: applyImpulse 事件 - 立即归零速度
            if Config.AntiKnockback_Enabled and eventName == "applyImpulse" then
                task.spawn(function()
                    task.wait(0.05)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            char.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        end)
                    end
                end)
            end
        end)
        OnClientEventHookInstalled = true
        if Config.DebugMode_Enabled then
            print("[KillSystem] OnClientEvent 监听器已安装 (AntiArrest=" .. tostring(Config.AntiArrest_Enabled)
                .. " AntiKnockback=" .. tostring(Config.AntiKnockback_Enabled) .. ")")
        end
    end)
end

-- 立即尝试安装
InstallOnClientEventHook()

-- 监听器循环
task.spawn(function()
    task.wait(2)
    while true do
        if not OnClientEventHookInstalled and (Config.AntiArrest_Enabled or Config.AntiKnockback_Enabled) then
            InstallOnClientEventHook()
        end
        -- 同时持续清除 Arrested 属性（防止被入狱）
        if Config.AntiArrest_Enabled then
            pcall(function()
                if LocalPlayer:GetAttribute("Arrested") then
                    LocalPlayer:SetAttribute("Arrested", nil)
                end
                if LocalPlayer:GetAttribute("PrepareToSetPrisonSentence") then
                    LocalPlayer:SetAttribute("PrepareToSetPrisonSentence", nil)
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ==========================================
-- [v10.60] 刷钱 1：钓鱼刷钱（高频 InvokeServer("catchFish")）
-- 已在 v10.57 实现 CatchFishSpam_Enabled，此处为新的开关别名
-- 实际使用 CatchFishSpam 或 MoneySpam_catchFish 任一均可
-- ==========================================
task.spawn(function()
    while true do
        if Config.MoneySpam_catchFish and PlayerFunc then
            pcall(function()
                PlayerFunc:InvokeServer("catchFish")
            end)
            task.wait(0.3)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.60] 刷钱 2：任务奖励刷（talkToMission 系列高频发包）
-- 协议分析：
--   talkToMission, ID.."harvested", v4 - 领取采集奖励
--   talkToMission, ID.."cargoLoaded" - 领取货物报酬
--   talkToMission, ID.."ingredients" - 领取材料
-- ==========================================
task.spawn(function()
    local missionIds = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }  -- 任务ID猜测范围
    local currentIndex = 1
    while true do
        if Config.MoneySpam_talkToMission and PlayerFunc then
            local missionId = missionIds[currentIndex]
            -- 尝试所有 4 种任务子状态
            for _, action in ipairs({ "harvested", "cargoLoaded", "ingredients", "playerNearby" }) do
                pcall(function()
                    PlayerFunc:InvokeServer("talkToMission", tostring(missionId) .. action, {})
                end)
                pcall(function()
                    PlayerFunc:InvokeServer("talkToMission", tostring(missionId) .. action)
                end)
            end
            currentIndex = currentIndex + 1
            if currentIndex > #missionIds then currentIndex = 1 end
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.60] 刷钱 3：任务完成刷（高频 FireServer("questCompleted")）
-- 协议分析：
--   FireServer("questCompleted", p1) - 领取任务奖励
--   FireServer("guideCompleted", p1, p2) - 领取教程奖励
-- ==========================================
task.spawn(function()
    local questIds = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }
    local currentIndex = 1
    while true do
        if Config.MoneySpam_questCompleted and PlayerEvent then
            local questId = questIds[currentIndex]
            pcall(function()
                PlayerEvent:FireServer("questCompleted", questId)
            end)
            pcall(function()
                PlayerEvent:FireServer("guideCompleted", questId, {})
            end)
            pcall(function()
                PlayerEvent:FireServer("tipLearned", "reward", nil)
            end)
            currentIndex = currentIndex + 1
            if currentIndex > #questIds then currentIndex = 1 end
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.60] 刷钱 4：自动复活（高频 FireServer("revive")）
-- 协议分析：FireServer("revive") 无参数，请求服务端复活自己
-- 配合死亡后立即复活，可领到某些复活奖励或快速回到战场
-- ==========================================
task.spawn(function()
    while true do
        if Config.MoneySpam_revive and PlayerEvent then
            pcall(function()
                PlayerEvent:FireServer("revive")
            end)
            task.wait(2)  -- 不宜过快，避免服务端限制
        else
            task.wait(3)
        end
    end
end)

-- ==========================================
-- [v10.61 新增/修复功能]
-- 1. GodMode 真正防止死亡：HumanoidHealth 属性设置 + ApplyImpulse 拦截 + DeathState 拦截
-- 2. 修复 Noclip：不再扫描所有车辆（防止车辆掉地底），只处理玩家自身+驾驶的车辆
-- 3. BrutalDamage 改为 FireServer("damage",...) 真正发包
-- 4. ClientStamina/ClientFood 改为 LocalPlayer:SetAttribute 客户端属性（不发包）
-- 5. 移除 BootSequence 中的"反作弊模块"清单（用户反馈不需要自动开启）
-- 6. 新增车辆功能：防车盗窃 / 车锁刷 / 车辆装饰刷 / 车辆清洁刷 / 大灯刷 / 警笛刷 / 喇叭刷
-- 7. 修复功能无法关闭：补充关闭回调清理状态
-- ==========================================

-- ==========================================
-- [v10.61] GodMode 真正防死亡：服务端检测死亡的关键是 Humanoid.Health<=0
-- 关键修复：之前只设置 Health=MaxHealth 不够，因为服务端在死亡瞬间会触发 Died 事件
-- 解决方案：
--   1. 在 Heartbeat 高频设置 Health=MaxHealth（覆盖服务端扣血）
--   2. Hook Humanoid.Died 事件：防止死亡触发的回调和重生流程
--   3. Hook HealthChanged：检测血量低于阈值立即恢复
--   4. 设置 RequiresNeckline=false / BreakJointsOnDeath=false 防止物理死亡
-- ==========================================
local GodModeRealHookInstalled = false
local function InstallGodModeRealHook()
    if GodModeRealHookInstalled then return end
    if not Config.GodModeHumanoidHardening_Enabled then return end

    pcall(function()
        -- 持续监听 CharacterAdded
        LocalPlayer.CharacterAdded:Connect(function(char)
            if not Config.GodModeHumanoidHardening_Enabled then return end
            task.wait(0.5)  -- 等待 Humanoid 加载
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            -- 1. 防止 BreakJointsOnDeath
            pcall(function() hum.BreakJointsOnDeath = false end)
            -- 2. 禁用 Dead/Physics 状态
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false) end)
            -- 3. 设置 MaxHealth 和 Health 持续保持高血量
            pcall(function() hum.MaxHealth = 99999 end)
            pcall(function() hum.Health = 99999 end)

            -- 4. Hook HealthChanged：血量变化时立即恢复
            local conn
            conn = hum.HealthChanged:Connect(function(health)
                if not Config.GodModeHumanoidHardening_Enabled then
                    if conn then conn:Disconnect() end
                    return
                end
                if health < hum.MaxHealth * 0.5 then
                    pcall(function() hum.Health = hum.MaxHealth end)
                end
            end)

            -- 5. Hook Died 事件：阻止死亡流程
            char:WaitForChild("Humanoid").Died:Connect(function()
                if Config.GodModeHumanoidHardening_Enabled then
                    pcall(function()
                        -- 强制复活：通过 SetAttribute 标记未死亡
                        LocalPlayer:SetAttribute("ForceAlive", true)
                        -- 重置 Humanoid 状态
                        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        -- 立即恢复血量
                        hum.Health = hum.MaxHealth
                    end)
                end
            end)
        end)
        GodModeRealHookInstalled = true
    end)
end
InstallGodModeRealHook()

-- 持续监控并安装
task.spawn(function()
    task.wait(2)
    while true do
        if Config.GodModeHumanoidHardening_Enabled and not GodModeRealHookInstalled then
            InstallGodModeRealHook()
        end
        -- 同时持续设置当前角色的 Health（覆盖服务端扣血）
        if Config.GodModeHumanoidHardening_Enabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        pcall(function() hum.BreakJointsOnDeath = false end)
                        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
                        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false) end)
                        -- 持续强制保持满血（关键修复：服务端扣血后客户端立即恢复）
                        if hum.MaxHealth < 99999 then
                            pcall(function() hum.MaxHealth = 99999 end)
                        end
                        if hum.Health < hum.MaxHealth then
                            pcall(function() hum.Health = hum.MaxHealth end)
                        end
                    end
                end
            end)
            task.wait(0.1)  -- 10Hz，足够快覆盖大多数伤害
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.61] ClientStamina/ClientFood 改为纯客户端属性设置（不发包）
-- 用户反馈："无限饥饿和无限体力在反作弊那就被开启了，我要的是直接客户端设置"
-- 实现方式：LocalPlayer:SetAttribute("Stamina", 100) + LocalPlayer:SetAttribute("Food", 100)
-- 同时保留 Core.stamina/food 设置（影响本地UI显示）
-- ==========================================
task.spawn(function()
    while true do
        if Config.ClientStamina_Enabled then
            pcall(function()
                -- 方式1：设置 Framework.Core.stamina（影响本地UI）
                local core = GetFrameworkCore()
                if core and core.stamina ~= 100 then
                    core.stamina = 100
                end
                -- 方式2：直接设置 LocalPlayer 属性（服务端会读取）
                LocalPlayer:SetAttribute("Stamina", 100)
                LocalPlayer:SetAttribute("stamina", 100)
                -- 方式3：尝试 setCoreStaminaOrFood（不发包只设置本地）
                if core and core.setCoreStaminaOrFood then
                    pcall(function() core.setCoreStaminaOrFood("stamina", 100) end)
                end
            end)
            task.wait(0.1)  -- 高频设置压过衰减
        else
            task.wait(2)
        end
    end
end)

task.spawn(function()
    while true do
        if Config.ClientFood_Enabled then
            pcall(function()
                -- 方式1：设置 Framework.Core.food
                local core = GetFrameworkCore()
                if core then
                    if core.food ~= 100 then
                        core.food = 100
                    end
                    -- 方式2：调用 setCoreStaminaOrFood 不发包版
                    if core.setCoreStaminaOrFood then
                        pcall(function() core.setCoreStaminaOrFood("food", 100) end)
                    end
                    -- 方式3：调用 changeFood 刷新UI
                    if core.changeFood then
                        pcall(function() core.changeFood(0) end)
                    end
                end
                -- 方式4：设置 LocalPlayer 属性
                LocalPlayer:SetAttribute("Food", 100)
                LocalPlayer:SetAttribute("food", 100)
            end)
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.61] BrutalDamage 修复：使用 FireServer("damage",...) 真正发包
-- v10.53 改造时改成"直接修改目标Humanoid.Health"，但因为客户端对其他玩家
-- 的 Humanoid 没有网络所有权，所以无效。用户反馈"暴力伤害完全是虚的"
-- 修复：使用 FireServer("damage", { bodyParts, shotCode, target, pos, damageFactor })
-- ==========================================
task.spawn(function()
    while true do
        if Config.BrutalDamage_Enabled then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local localPos = char.HumanoidRootPart.Position
                local remote = FetchRemote()
                if not remote then return end

                -- 全身体部位数组
                local allBodyParts = {
                    { "Head", 1 },
                    { "Torso", 2 },
                    { "LeftArm", 1 },
                    { "RightArm", 1 },
                    { "LeftLeg", 1 },
                    { "RightLeg", 1 }
                }

                local damageFactor = Config.BrutalDamage_Factor
                if Config.MaxDamageFactor_Enabled then damageFactor = 999 end

                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character
                        and player.Character:FindFirstChild("HumanoidRootPart")
                        and player.Character:FindFirstChild("Humanoid") then
                        local hum = player.Character.Humanoid
                        if hum.Health > 0 then
                            local targetPos = player.Character.HumanoidRootPart.Position
                            local dist = (targetPos - localPos).Magnitude
                            if dist < 1000 then
                                -- 移除目标的 BulletProof / SpawnProtection 让伤害生效
                                pcall(function() player.Character:SetAttribute("BulletProof", nil) end)
                                pcall(function() player.Character:SetAttribute("SpawnProtection", nil) end)

                                local shotCode = { localPos, (targetPos - localPos).Unit }

                                -- 多重伤害：发送 Config.BrutalDamage_MultiCount 次
                                for i = 1, Config.BrutalDamage_MultiCount do
                                    task.spawn(function()
                                        pcall(function()
                                            remote:FireServer("damage", {
                                                ["bodyParts"] = Config.AllBodyParts_Enabled
                                                    and allBodyParts or { { "Head", 1 } },
                                                ["shotCode"] = shotCode,
                                                ["pos"] = targetPos,
                                                ["target"] = player,
                                                ["damageFactor"] = damageFactor,
                                                ["bulletProofTool"] = false
                                            })
                                        end)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.61] 修复 Noclip：只处理玩家自身和驾驶的车辆
-- 之前会扫描50米内所有车辆设置 CanCollide=false，导致车辆（包括未驾驶的）
-- 掉入地底。修复：只对玩家自身和当前驾驶的车辆应用穿墙
-- ==========================================
-- 替换原 Unified Stepped Handler 中的 Noclip 部分（在原位置上修改）

-- ==========================================
-- [v10.61] 车辆功能 1：自动翻车复位（FireServer版）
-- 原 v10.53 版本使用 PivotTo 直接 CFrame 操控，但客户端对未驾驶的车辆没有
-- 网络所有权，PivotTo 无效。改用 FireServer("unflipVehicle", car)
-- ==========================================
local UnflipVehicleLastFire = 0
task.spawn(function()
    while true do
        if Config.UnflipVehicle_Enabled then
            if tick() - UnflipVehicleLastFire >= 2 then
                UnflipVehicleLastFire = tick()
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                    local localPos = char.HumanoidRootPart.Position
                    local remote = FetchRemote()
                    if not remote then return end

                    local vehicles = workspace:FindFirstChild("Gameplay")
                        and workspace.Gameplay:FindFirstChild("Vehicles")
                    if vehicles then
                        for _, car in ipairs(vehicles:GetChildren()) do
                            if car:IsA("Model") and car.PrimaryPart then
                                local dist = (car.PrimaryPart.Position - localPos).Magnitude
                                if dist < 30 then
                                    -- 检测翻车（UpVector.Y < 0.3）
                                    if car.PrimaryPart.CFrame.UpVector.Y < 0.3 then
                                        pcall(function()
                                            remote:FireServer("unflipVehicle", car)
                                        end)
                                        -- 同时尝试本地 PivotTo（如果玩家驾驶该车辆则有网络所有权）
                                        pcall(function()
                                            local pos = car.PrimaryPart.Position
                                            car:PivotTo(CFrame.new(pos))
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(1)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.61] 车辆功能 2：车锁刷（对所有附近车辆交替发送 lock/unlock）
-- FireServer("vehicle", "lock", value)
-- ==========================================
task.spawn(function()
    local lastLockTime = 0
    while true do
        if Config.VehicleLockSpam_Enabled then
            if tick() - lastLockTime >= 3 then
                lastLockTime = tick()
                pcall(function()
                    local remote = FetchRemote()
                    if not remote then return end
                    local vehicles = workspace:FindFirstChild("Gameplay")
                        and workspace.Gameplay:FindFirstChild("Vehicles")
                    if vehicles then
                        for _, car in ipairs(vehicles:GetChildren()) do
                            if car:IsA("Model") and car:FindFirstChild("Config") then
                                local locked = car.Config:FindFirstChild("Locked")
                                if locked then
                                    pcall(function()
                                        remote:FireServer("vehicle", "lock", locked.Value)
                                    end)
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(1)
        else
            task.wait(5)
        end
    end
end)

-- ==========================================
-- [v10.61] 车辆功能 3：车辆清洁刷
-- FireServer("vehicle", "cleanliness", 100, car)
-- ==========================================
task.spawn(function()
    local lastCleanTime = 0
    while true do
        if Config.VehicleCleanSpam_Enabled then
            if tick() - lastCleanTime >= 3 then
                lastCleanTime = tick()
                pcall(function()
                    local remote = FetchRemote()
                    if not remote then return end
                    local vehicles = workspace:FindFirstChild("Gameplay")
                        and workspace.Gameplay:FindFirstChild("Vehicles")
                    if vehicles then
                        for _, car in ipairs(vehicles:GetChildren()) do
                            if car:IsA("Model") then
                                pcall(function()
                                    remote:FireServer("vehicle", "cleanliness", 100, car)
                                end)
                            end
                        end
                    end
                end)
            end
            task.wait(1)
        else
            task.wait(5)
        end
    end
end)

-- ==========================================
-- [v10.61] 车辆功能 4：大灯闪烁刷
-- FireServer("vehicle", "headlights", not locked.Value)
-- ==========================================
task.spawn(function()
    local lastHeadlightTime = 0
    while true do
        if Config.HeadlightSpam_Enabled then
            if tick() - lastHeadlightTime >= 0.5 then
                lastHeadlightTime = tick()
                pcall(function()
                    local remote = FetchRemote()
                    if not remote then return end
                    local vehicles = workspace:FindFirstChild("Gameplay")
                        and workspace.Gameplay:FindFirstChild("Vehicles")
                    if vehicles then
                        for _, car in ipairs(vehicles:GetChildren()) do
                            if car:IsA("Model") and car:FindFirstChild("Config") then
                                local locked = car.Config:FindFirstChild("Locked")
                                if locked then
                                    pcall(function()
                                        remote:FireServer("vehicle", "headlights", not locked.Value)
                                    end)
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(0.2)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.61] 车辆功能 5：警笛刷（对所有附近车辆交替 muteSiren true/false）
-- FireServer("vehicle", "muteSiren", false)
-- FireServer("vehicle", "muteSiren", true)
-- ==========================================
task.spawn(function()
    local lastSirenTime = 0
    while true do
        if Config.SirenSpam_Enabled then
            if tick() - lastSirenTime >= 0.3 then
                lastSirenTime = tick()
                pcall(function()
                    local remote = FetchRemote()
                    if not remote then return end
                    local vehicles = workspace:FindFirstChild("Gameplay")
                        and workspace.Gameplay:FindFirstChild("Vehicles")
                    if vehicles then
                        for _, car in ipairs(vehicles:GetChildren()) do
                            if car:IsA("Model") then
                                pcall(function() remote:FireServer("vehicle", "muteSiren", false) end)
                                pcall(function() remote:FireServer("vehicle", "muteSiren", true) end)
                            end
                        end
                    end
                end)
            end
            task.wait(0.2)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.61] 车辆功能 6：喇叭刷（指示灯闪烁）
-- FireServer("vehicle", "indicator", 3)
-- FireServer("vehicle", "indicator", 0)
-- ==========================================
task.spawn(function()
    local lastHornTime = 0
    while true do
        if Config.HornSpam_Enabled then
            if tick() - lastHornTime >= 0.2 then
                lastHornTime = tick()
                pcall(function()
                    local remote = FetchRemote()
                    if not remote then return end
                    local vehicles = workspace:FindFirstChild("Gameplay")
                        and workspace.Gameplay:FindFirstChild("Vehicles")
                    if vehicles then
                        for _, car in ipairs(vehicles:GetChildren()) do
                            if car:IsA("Model") then
                                pcall(function() remote:FireServer("vehicle", "indicator", 3) end)
                                pcall(function() remote:FireServer("vehicle", "indicator", 0) end)
                            end
                        end
                    end
                end)
            end
            task.wait(0.1)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.61] 车辆功能 7：防车盗窃（持续通知服务器车辆未被盗）
-- FireServer("isPlayersVehicleStolen", car, false)
-- ==========================================
task.spawn(function()
    local lastAntiStealTime = 0
    while true do
        if Config.VehicleAntiSteal_Enabled then
            if tick() - lastAntiStealTime >= 5 then
                lastAntiStealTime = tick()
                pcall(function()
                    local remote = FetchRemote()
                    if not remote then return end
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                    local localPos = char.HumanoidRootPart.Position
                    local vehicles = workspace:FindFirstChild("Gameplay")
                        and workspace.Gameplay:FindFirstChild("Vehicles")
                    if vehicles then
                        for _, car in ipairs(vehicles:GetChildren()) do
                            if car:IsA("Model") and car.PrimaryPart then
                                local dist = (car.PrimaryPart.Position - localPos).Magnitude
                                if dist < 50 then
                                    pcall(function()
                                        remote:FireServer("isPlayersVehicleStolen", car, false)
                                    end)
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(1)
        else
            task.wait(5)
        end
    end
end)

-- ==========================================
-- [v10.61] 车辆功能 8：车辆锁定（持续通知车辆已锁）
-- FireServer("vehicle", "lock", true) - 对附近车辆持续锁定
-- ==========================================
task.spawn(function()
    local lastLockProtectTime = 0
    while true do
        if Config.VehicleLockProtect_Enabled then
            if tick() - lastLockProtectTime >= 2 then
                lastLockProtectTime = tick()
                pcall(function()
                    local remote = FetchRemote()
                    if not remote then return end
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                    local localPos = char.HumanoidRootPart.Position
                    local vehicles = workspace:FindFirstChild("Gameplay")
                        and workspace.Gameplay:FindFirstChild("Vehicles")
                    if vehicles then
                        for _, car in ipairs(vehicles:GetChildren()) do
                            if car:IsA("Model") and car.PrimaryPart then
                                local dist = (car.PrimaryPart.Position - localPos).Magnitude
                                if dist < 50 then
                                    pcall(function()
                                        remote:FireServer("vehicle", "lock", true)
                                    end)
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(1)
        else
            task.wait(5)
        end
    end
end)

-- ==========================================
-- [v10.62 全面修复 + 新增车辆速度/飞行功能]
-- 1. GodMode 真正硬化：Hook Humanoid:ChangeState + SetStateEnabled + HealthChanged
-- 2. GodModeBulletProof：移除 LocalPlayer 上也设置 BulletProof
-- 3. Noclip 关闭后恢复 CanCollide=true
-- 4. 修复通缉消除进度：检查 WantedPoints 衰减
-- 5. 修复近战无冷却：直接 require(weapon.Config).REST_TIME = 0
-- 6. 修复武器强化：修正 Config 路径 Stuff.Weapons.<ID>.<Name>.Config
-- 7. 修复 BrutalDamage：target 改为 Player 实例
-- 8. 移除无效刷钱功能（paycheck 不可注入），改为钓鱼/任务等真实途径
-- 9. 新增车辆速度修改
-- 10. 飞行功能已存在（Fly_Enabled/SACFly_Enabled），保留并修复
-- ==========================================

-- ==========================================
-- [v10.62] GodMode 真正硬化：Hook Humanoid:ChangeState 防止 Dead 状态
-- 之前 SetStateEnabled(Dead, false) 不够，因为 characterDied 函数会主动
-- 调用 Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
-- ==========================================
local GodModeChangeStateHookInstalled = false
local function InstallGodModeChangeStateHook()
    if GodModeChangeStateHookInstalled then return end
    if not Config.GodModeHumanoidHardening_Enabled then return end

    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            -- 拦截 Humanoid:ChangeState(Dead) 调用
            if Config.GodModeHumanoidHardening_Enabled
                and method == "ChangeState" and self:IsA("Humanoid") then
                local args = { ... }
                if args[1] == Enum.HumanoidStateType.Dead then
                    -- 改为 GettingUp 状态防止死亡
                    return oldNamecall(self, Enum.HumanoidStateType.GettingUp)
                end
            end
            return oldNamecall(self, ...)
        end)
        GodModeChangeStateHookInstalled = true
    end)

    -- 后备：直接 hook Humanoid 的 ChangeState 函数
    if not GodModeChangeStateHookInstalled then
        pcall(function()
            local mt = getrawmetatable(game)
            local oldIndex = mt.__index
            setreadonly(mt, false)
            mt.__index = function(t, k)
                if Config.GodModeHumanoidHardening_Enabled
                    and k == "ChangeState" and t:IsA("Humanoid") then
                    return function(self, state, ...)
                        if state == Enum.HumanoidStateType.Dead then
                            state = Enum.HumanoidStateType.GettingUp
                        end
                        return oldIndex(t, k)(self, state, ...)
                    end
                end
                return oldIndex(t, k)
            end
            setreadonly(mt, true)
            GodModeChangeStateHookInstalled = true
        end)
    end
end

task.spawn(function()
    task.wait(2)
    while true do
        if Config.GodModeHumanoidHardening_Enabled and not GodModeChangeStateHookInstalled then
            InstallGodModeChangeStateHook()
        end
        task.wait(2)
    end
end)

-- ==========================================
-- [v10.62] GodMode 高频强制保持血量 + 防止 Died 事件
-- 必须高频（每帧）覆盖服务端扣血
-- [v10.63优化] 仅在 GodModeHumanoidHardening_Enabled=true 时执行
--              并缓存 Humanoid 引用避免每帧 FindFirstChildOfClass
-- ==========================================
local _lastGodModeCharCheck = 0
local _cachedGodModeHum = nil
RunService.Heartbeat:Connect(function()
    if not Config.GodModeHumanoidHardening_Enabled then return end  -- [v10.63] 早返回减少开销
    pcall(function()
        local char = LocalPlayer.Character
        if not char then _cachedGodModeHum = nil return end
        -- [v10.63] 缓存 Humanoid 引用，0.5 秒重新查找一次以应对角色重生
        if not _cachedGodModeHum or not _cachedGodModeHum.Parent or tick() - _lastGodModeCharCheck > 0.5 then
            _cachedGodModeHum = char:FindFirstChildOfClass("Humanoid")
            _lastGodModeCharCheck = tick()
        end
        local hum = _cachedGodModeHum
        if hum then
            -- 防止 BreakJointsOnDeath
            if hum.BreakJointsOnDeath ~= false then
                hum.BreakJointsOnDeath = false
            end
            -- 禁用 Dead 和 Physics 状态（仅在变更时设置，避免每帧写入）
            -- 这里仍每帧执行因为 SetStateEnabled 是幂等的
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false) end)
            -- 强制 MaxHealth
            if hum.MaxHealth < 99999 then
                hum.MaxHealth = 99999
            end
            -- 每帧强制保持满血（覆盖服务端扣血）
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end)
end)

-- ==========================================
-- [v10.62] GodModeBulletProof 增强：同时在 LocalPlayer 和 Character 上设置
-- 之前只在 Character 上设置，但 canCombat 可能查 LocalPlayer
-- ==========================================
task.spawn(function()
    while true do
        if Config.GodModeBulletProof_Enabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    -- Character 上设置
                    if not char:GetAttribute("BulletProof") then
                        char:SetAttribute("BulletProof", true)
                    end
                    if not char:GetAttribute("SpawnProtection") then
                        char:SetAttribute("SpawnProtection", true)
                    end
                end
                -- LocalPlayer 上也设置（双重保险）
                if not LocalPlayer:GetAttribute("BulletProof") then
                    LocalPlayer:SetAttribute("BulletProof", true)
                end
                if not LocalPlayer:GetAttribute("SpawnProtection") then
                    LocalPlayer:SetAttribute("SpawnProtection", true)
                end
                -- 同时在 HumanoidRootPart 上也设置
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    if not root:GetAttribute("BulletProof") then
                        root:SetAttribute("BulletProof", true)
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.62c] Noclip 关闭后智能恢复 CanCollide
-- 修复 v10.62b 中遗留问题：穿墙关闭车辆依然可以穿墙
-- 原因：Stepped 处理器在 Noclip 开启时每帧给车辆 CanCollide=false
--       但 Noclip_Enabled 回调只在开关变化时触发一次
--       如果用户在 Noclip 开启期间上车/下车，新驾驶的车辆不会被恢复
-- 修复方案：
--   - Noclip 关闭时持续恢复所有相关车辆碰撞
--   - 使用智能判断：跳过 Accessory，仅恢复 BasePart 实体部件
--   - 包含玩家当前驾驶的车辆 + 附近 30 米内最近 5 辆车
--   - 持续恢复约 3 秒确保覆盖所有情况
-- ==========================================
local NoclipRestoreEndTime = 0
local NoclipLastEnabledState = false

-- 监听 Noclip 状态变化，设置恢复窗口
task.spawn(function()
    while true do
        local currentState = Config.Noclip_Enabled
        -- 当 Noclip 从 true 变为 false 时，启动 3 秒恢复窗口
        if NoclipLastEnabledState and not currentState then
            NoclipRestoreEndTime = tick() + 3
        end
        NoclipLastEnabledState = currentState
        task.wait(0.1)
    end
end)

-- 恢复函数：跳过 Accessory 部件，恢复 BasePart 部件
local function RestorePartCollision(part)
    if not part or not part.Parent then return end
    if not part:IsA("BasePart") then return end

    -- 跳过 HumanoidRootPart 和 Head（这两个默认 CanCollide=false）
    if part.Name == "HumanoidRootPart" or part.Name == "Head" then return end

    -- 跳过 Accessory 内的部件（帽子/头发/饰品等不应参与碰撞）
    local parent = part.Parent
    while parent do
        if parent:IsA("Accessory") or parent:IsA("Hat") or parent.Name == "Accessory" then
            return
        end
        if parent:IsA("Model") or parent == workspace then break end
        parent = parent.Parent
    end

    -- 恢复 CanCollide=true
    if part.CanCollide ~= true then
        pcall(function() part.CanCollide = true end)
    end
end

-- Stepped 监听器：在恢复窗口内持续恢复车辆碰撞
RunService.Stepped:Connect(function()
    if tick() < NoclipRestoreEndTime then
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end

            -- 1. 恢复玩家自身部件
            for _, part in ipairs(char:GetDescendants()) do
                RestorePartCollision(part)
            end

            -- 2. 恢复当前驾驶的车辆
            local seat = char:FindFirstChild("Seat")
            if seat and seat:IsA("Weld") and seat.Part1 then
                local vehicle = seat.Part1.Parent
                if vehicle then
                    for _, part in ipairs(vehicle:GetDescendants()) do
                        RestorePartCollision(part)
                    end
                end
            end

            -- 3. 恢复附近 30 米内最近 5 辆车
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local localPos = root.Position
                local vehicles = workspace:FindFirstChild("Gameplay")
                    and workspace.Gameplay:FindFirstChild("Vehicles")
                if vehicles then
                    local nearbyVehicles = {}
                    for _, car in ipairs(vehicles:GetChildren()) do
                        if car:IsA("Model") and car.PrimaryPart then
                            local dist = (car.PrimaryPart.Position - localPos).Magnitude
                            if dist < 30 then
                                table.insert(nearbyVehicles, { car = car, dist = dist })
                            end
                        end
                    end
                    -- 按距离排序，只处理最近 5 辆
                    table.sort(nearbyVehicles, function(a, b) return a.dist < b.dist end)
                    for i = 1, math.min(5, #nearbyVehicles) do
                        local car = nearbyVehicles[i].car
                        for _, part in ipairs(car:GetDescendants()) do
                            RestorePartCollision(part)
                        end
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- [v10.62] 近战无冷却：修正 Config 路径
-- 真实路径：game.ReplicatedStorage.Stuff.Weapons.<ID>.<WeaponName>.Config
-- 之前 ForEachWeaponConfig 路径错误，找不到模块
-- ==========================================
local function ForEachWeaponConfigV62(fn)
    -- 路径1：ReplicatedStorage.Stuff.Weapons.<ID>.<WeaponName>.Config
    pcall(function()
        local stuff = game.ReplicatedStorage:FindFirstChild("Stuff")
        if stuff then
            local weapons = stuff:FindFirstChild("Weapons")
            if weapons then
                for _, idFolder in ipairs(weapons:GetChildren()) do
                    if idFolder:IsA("Folder") then
                        for _, weaponModel in ipairs(idFolder:GetChildren()) do
                            local cfg = weaponModel:FindFirstChild("Config")
                            if cfg and cfg:IsA("ModuleScript") then
                                pcall(fn, cfg)
                            end
                        end
                    end
                end
            end
        end
    end)
    -- 路径2：当前已装备的 Tool.Config
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    local cfgModule = tool:FindFirstChild("Config")
                    if cfgModule and cfgModule:IsA("ModuleScript") then
                        pcall(fn, cfgModule)
                    end
                end
            end
        end
    end)
    -- 路径3：Backpack 中的 Tool.Config
    pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local cfg = tool:FindFirstChild("Config")
                    if cfg and cfg:IsA("ModuleScript") then
                        pcall(fn, cfg)
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- [v10.62] 修复所有武器强化功能：使用正确的 Config 路径
-- RPM/RELOAD_TIME/BULLET_AMOUNT/TR_DIFF/DAMAGE/REST_TIME/MAX_DISTANCE
-- 同时修改 IntValue 类型的 Ammo/TotalAmmo（弹药实际存储位置）
-- ==========================================
task.spawn(function()
    while true do
        if Config.Weapon_RapidFire or Config.Weapon_FastReload or Config.Weapon_ShotgunBoost
            or Config.Weapon_MaxDamage or Config.Weapon_NoMeleeCooldown
            or Config.Weapon_BulletAmount_Enabled or Config.Weapon_NoSpread_Enabled
            or Config.Weapon_InfiniteRange_Enabled or Config.Weapon_AutoReload_Enabled then
            ForEachWeaponConfigV62(function(cfgModule)
                local ok, cfg = pcall(require, cfgModule)
                if ok and cfg and type(cfg) == "table" then
                    -- === ModuleScript 字段 ===
                    if Config.Weapon_RapidFire then
                        pcall(function() cfg.RPM = 9999 end)
                        pcall(function() cfg.SHOOT_MODE = 2 end)  -- 自动模式
                    end
                    if Config.Weapon_FastReload then
                        pcall(function() cfg.RELOAD_TIME = 0 end)
                    end
                    if Config.Weapon_ShotgunBoost then
                        pcall(function()
                            if cfg.CATEGORY == "Shotgun" then
                                cfg.BULLET_AMOUNT = 50
                                cfg.TR_DIFF = 0
                            end
                        end)
                    end
                    if Config.Weapon_MaxDamage then
                        pcall(function() cfg.DAMAGE = 999 end)
                    end
                    if Config.Weapon_NoMeleeCooldown then
                        pcall(function()
                            if cfg.CATEGORY == "Melee" then
                                cfg.REST_TIME = 0
                            end
                        end)
                    end
                    if Config.Weapon_BulletAmount_Enabled then
                        pcall(function() cfg.BULLET_AMOUNT = Config.Weapon_BulletAmount_Value end)
                    end
                    if Config.Weapon_NoSpread_Enabled then
                        pcall(function() cfg.TR_DIFF = 0 end)
                        pcall(function() cfg.SPREAD = 0 end)
                        pcall(function() cfg.ACCURACY = 0.001 end)
                    end
                    if Config.Weapon_InfiniteRange_Enabled then
                        pcall(function() cfg.MAX_DISTANCE = 99999 end)
                        pcall(function() cfg.RANGE = 99999 end)
                    end
                end
            end)

            -- 同时修改 Tool.Config 文件夹中的 IntValue（Ammo/TotalAmmo）
            -- 这是真实弹药存储位置
            pcall(function()
                local function patchToolIntValues(tool)
                    local cfgFolder = tool:FindFirstChild("Config")
                    if not cfgFolder then return end
                    -- 检查是否为 Folder（包含 IntValue）
                    if cfgFolder:IsA("Folder") then
                        local ammo = cfgFolder:FindFirstChild("Ammo")
                        local totalAmmo = cfgFolder:FindFirstChild("TotalAmmo")
                        local speedLimiter = cfgFolder:FindFirstChild("SpeedLimiter")

                        -- 无限弹药（最大值999）
                        if Config.Weapon_AutoReload_Enabled or Config.Weapon_MaxDamage then
                            if ammo and ammo:IsA("IntValue") then
                                if ammo.Value < 999 then
                                    ammo.Value = 999
                                end
                            end
                            if totalAmmo and totalAmmo:IsA("IntValue") then
                                if totalAmmo.Value < 9999 then
                                    totalAmmo.Value = 9999
                                end
                            end
                        end
                    end
                end

                local char = LocalPlayer.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            pcall(patchToolIntValues, tool)
                        end
                    end
                end
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            pcall(patchToolIntValues, tool)
                        end
                    end
                end
            end)
        end
        task.wait(0.3)  -- 提高频率
    end
end)

-- ==========================================
-- [v10.62] 车辆速度修改：覆盖 Config.MAX_SPEED + 直接写 LinearVelocity
-- 真实路径：game.ReplicatedStorage.Stuff.Vehicles.<Team>.<ID>.<VehicleName>.Config
-- 同时修改已生成车辆的 _Chassis.Center.LinearVelocity.MaxForce
-- ==========================================
task.spawn(function()
    while true do
        if Config.VehicleSpeedHack_Enabled then
            pcall(function()
                -- 1. 修改 ReplicatedStorage 中的车辆 Config 模板
                local stuff = game.ReplicatedStorage:FindFirstChild("Stuff")
                if stuff then
                    local vehicles = stuff:FindFirstChild("Vehicles")
                    if vehicles then
                        for _, teamFolder in ipairs(vehicles:GetChildren()) do
                            if teamFolder:IsA("Folder") then
                                for _, idFolder in ipairs(teamFolder:GetChildren()) do
                                    if idFolder:IsA("Folder") then
                                        for _, vehicleModel in ipairs(idFolder:GetChildren()) do
                                            local cfgModule = vehicleModel:FindFirstChild("Config")
                                            if cfgModule and cfgModule:IsA("ModuleScript") then
                                                local ok, cfg = pcall(require, cfgModule)
                                                if ok and cfg then
                                                    pcall(function() cfg.MAX_SPEED = Config.VehicleSpeedHack_Value end)
                                                    pcall(function() cfg.ACCELERATION = 1 end)  -- 加速更快
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- 2. 修改已生成车辆（workspace.Gameplay.Vehicles.*）的 Config 文件夹
                local vehiclesFolder = workspace:FindFirstChild("Gameplay")
                    and workspace.Gameplay:FindFirstChild("Vehicles")
                if vehiclesFolder then
                    local char = LocalPlayer.Character
                    local localPos = char and char:FindFirstChild("HumanoidRootPart")
                        and char.HumanoidRootPart.Position or Vector3.new()
                    for _, car in ipairs(vehiclesFolder:GetChildren()) do
                        if car:IsA("Model") and car.PrimaryPart then
                            local dist = (car.PrimaryPart.Position - localPos).Magnitude
                            if dist < 200 then  -- 仅影响附近200米车辆
                                -- 修改 SpeedLimiter IntValue
                                local cfgFolder = car:FindFirstChild("Config")
                                if cfgFolder and cfgFolder:IsA("Folder") then
                                    local speedLimiter = cfgFolder:FindFirstChild("SpeedLimiter")
                                    if speedLimiter and speedLimiter:IsA("IntValue") then
                                        if speedLimiter.Value ~= 0 then
                                            speedLimiter.Value = 0  -- 关闭限速器
                                        end
                                    end
                                end
                                -- 修改 _Chassis.Center.LinearVelocity
                                local chassis = car:FindFirstChild("_Chassis")
                                if chassis then
                                    local center = chassis:FindFirstChild("Center")
                                    if center then
                                        local lv = center:FindFirstChildOfClass("LinearVelocity")
                                        if lv then
                                            pcall(function() lv.MaxForce = math.huge end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        else
            task.wait(2)
        end
    end
end)

-- ==========================================
-- [v10.62] 修复通缉消除进度显示
-- GodMode 让服务端检测异常状态后停止 WantedPoints 衰减
-- 解决方案：定期清除可能阻塞的属性 + 强制刷新 UI
-- ==========================================
task.spawn(function()
    while true do
        if Config.GodModeHumanoidHardening_Enabled or Config.GodModeBulletProof_Enabled then
            pcall(function()
                -- 移除可能阻塞通缉衰减的属性
                -- 不要移除 Arrested（防入狱需要它）但移除其他可能影响通缉的属性
                if LocalPlayer:GetAttribute("FreezeWantedLevel") then
                    -- 仅在用户没主动开启 AntiArrest 时清除
                    if not Config.AntiArrest_Enabled then
                        LocalPlayer:SetAttribute("FreezeWantedLevel", nil)
                    end
                end
            end)
            task.wait(5)
        else
            task.wait(10)
        end
    end
end)

-- ==========================================
-- [v10.62] 修复刷钱：完全重写
-- paycheck 不可注入（服务端权威）— 移除
-- 改为真正可能有效的途径：
-- 1. 钓鱼刷钱（catchFish，最有可能）
-- 2. 取消开发任务奖励刷（无效，已移除）
-- 3. 修改 Core 钱包变量（仅本地UI显示，不真实增加）
-- 4. cashDrop 拾取地面现金（如果地图有 CashDrop 实例）
-- ==========================================

-- 修复 catchFish：直接 PlayerFunc:InvokeServer（不通过调用 limit）
task.spawn(function()
    while true do
        if Config.MoneySpam_catchFish and PlayerFunc then
            pcall(function()
                PlayerFunc:InvokeServer("catchFish")
            end)
            task.wait(0.5)  -- 2Hz
        else
            task.wait(2)
        end
    end
end)

-- 新增：捡取地图上所有 CashDrop 实例（无需靠近）
task.spawn(function()
    while true do
        if Config.MoneySpam_cashDropPickup and PlayerFunc then
            pcall(function()
                -- 扫描 workspace 下的所有 CashDrop 实例
                for _, desc in ipairs(workspace:GetDescendants()) do
                    if desc.Name == "CashDrop" or desc.Name:find("Cash") then
                        pcall(function()
                            PlayerFunc:InvokeServer("cashDrop", desc)
                        end)
                        pcall(function()
                            PlayerFunc:InvokeServer("getItem", desc)
                        end)
                    end
                end
            end)
            task.wait(2)
        else
            task.wait(5)
        end
    end
end)

-- 新增：直接修改 Framework.Core 中的 Cash 显示（仅本地视觉）
task.spawn(function()
    while true do
        if Config.MoneySpam_localVisualOnly then
            pcall(function()
                local core = GetFrameworkCore()
                if core then
                    -- 尝试直接修改本地 Cash 变量（仅视觉）
                    if core.cash then core.cash = 9999999 end
                    if core.money then core.money = 9999999 end
                    if core.Cash then core.Cash = 9999999 end
                end
                -- 通过 AccessData 读取/写入（仅本地）
                local char = LocalPlayer.Character
                if char then
                    char:SetAttribute("Cash", 9999999)
                    char:SetAttribute("Money", 9999999)
                end
                LocalPlayer:SetAttribute("Cash", 9999999)
                LocalPlayer:SetAttribute("Money", 9999999)
            end)
            task.wait(2)
        else
            task.wait(5)
        end
    end
end)

-- ==========================================
-- [开场动画启动 - v10.62c]
-- 在所有功能初始化完成后启动BootSequence
-- ==========================================
task.spawn(function()
    pcall(BootSequence)
end)
