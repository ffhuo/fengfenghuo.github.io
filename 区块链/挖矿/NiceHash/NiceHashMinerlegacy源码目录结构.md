# NiceHashMiner源码

## 1.目录结构

```txt
+ NiceHashMinerlegacy
      + 3rdParty
            - ADL.cs                               //AMD显示库
            - NVAPI.cs                             //NVIDIA开发库
            - PInvookeDelegateFactory.cs           //提供创建什么代理的方法
      + Algorithms                                 //算法相关
            - Algorithm.cs                         //提供当前算法信息（包括收益、预计收益等）方法
            - DualAlgorithm.cs                     //二重算法，继承自算法，双挖算法信息？方法
      + Benchmarking                               //基准测试测试算力相关
            + BechHelpers                          //提供三个测试项
                  - ClaymoreZcashBenchHelper.cs    //ClaymoreZcash测试方法
                  - CpuBenchHelp.cs                //Cpu测试方法
                  - Powerhelper.cs                 //Power测试方法
            - BenchmarkHandler.cs                  //提供基准测试方法（开始，完成等）继承自IBenchmarkComunicator
      + Confings                                   //存储相关运行配置数据文件
            + ConfigJsonFile                       //配置数据文件
                  - ConfigFile.cs                  //配置文件基类方法
                  - DeviceBenchmarkConfigFile.cs   //存储基准测试数据文件，继承自ConfigFile
                  - FOLDERS.cs                     //定义文件存储目录
                  - GeneralConfigFile.cs           //运行、设置相关信息存储，继承自ConfigFile
            + Data                                 //数据相关目录
                  - AlgorithmConfig.cs             //定义算法相关数据参数
                  - BenchmarkTimeLimitsConfig.cs   //定义基准测试相关数据参数
                  - ComputeDeviceConfig.cs         //计算设备识别相关数据参数
                  - DeviceBenchmarkConfig.cs       //设备基准测试相关参数包括算法参数、双重算法参数等
                  - DeviceDetectionConfig.cs       //设备检测数据参数，是AMD还是NVIDIA
                  - DualAlgorithmConfig.cs         //定义双重算法相关算法参数
                  - GeneralConfig.cs               //运行、设置相关参数定义及初始化
            - ConfigManager.cs                     //提供数据保存、备份、恢复、提交等方法
      + Devies                                     //设备相关数据方法
            + ComputeDevice                        //CPU，NVIDIA，AMD三种计算设备数据方法
                  - AmdComputeDevice.cs            //Amd设备信息，Amd设备信息获取，使用ADL库
                  - ComputeDevice.cs               //基类，设备详细信息参数，提供基础获取设备信息方法
                  - CpuComputeDevice.cs            //CPU信息，继承自ComputeDevice
                  - CudaComputeDevice.cs           //NVIDIA设备信息，NVIDIA设备信息获取，使用NVPI库
            - AmdGpuDevice.cs                      //Amd设备参数
            - ComputeDeviceManager.cs              //定义设备参数，提供设备信息查询接口
            - CPUUtils.cs                          //提供支持CPU指令集查询接口
            - CUDA_Unsupported.cs                  //定义不支持的NVIDIA产品，提供查询接口
            - CudaDevice.cs                        //Cuda设备参数
            - GroupAlgorithms.cs                   //根据设备设置不同算法运行参数
            - GroupNams.cs                         //提供设备名获取方法
            - OpenCLDevice.cs                      //定义设备名，类型，版本，驱动等参数
      + Enums                                      //枚举类型定义
            - AlgorithmBenchmarkSettingsType.cs    //基准测试算法类型
            - AlgorithmType.cs                     //算法类型
            - BenchmarkPerformanceType.cs          //基准测试方法类型
            - BenchmarkProcessStatus.cs            //基准测试进程状态类型
            - CpuExtensionType.cs                  //CPU指令集类型
            - DagGenerationType.cs                 //DAG生成类型
            - DeviceGroupType.cs                   //设备组类型CPU、AMD系、NVIDIA各系
            - DeviceMiningStatus.cs                //挖矿状态，不支持、无可用算法、无设备、可用
            - DeviceType.cs                        //设备类型CPU、AMD、NVIDIA
            - LanguageType.cs                      //界面语言
            - MinerApiReadStatus.cs                //
            - MinerBaseType.cs                     //矿工基础类型cpu矿工、gpu矿工、以太矿工等
            - MinerOptionFlagType.cs               //矿工设置参数单参、多参、重复多参
            - MinerStopType.cs                     //挖矿结束类型，切换、终止、强制终止
            - MinerType.cs                         //矿工类型
            - NhmConectionType.cs                  //服务器连接类型，TCP、SSL、LOCKED
            - TimeUnitType.cs                      //时间单位，时、天、周、月、年
            - Use3rdPartyminers.cs                 //第三方矿工，未知、是、否
      + Forms                                      //UI
      + Interfaces                                 //UI方法定义
            - IBenchmarkCalculation.cs             //
            - IBenchmarkComunicator.cs             //
            - IBenchmarkForm.cs                    //
            - IListItemCheckColorSetter.cs         //
            - IMessageNotifier.cs                  //
            - IMinerUpdateIndicator.cs             //
      + langs                                      //语言包
      + Miners                                     //挖矿相关
            + Equihash                             //Equihash算法挖矿
                  - ClaymoreZcashMiner.cs          //继承ClaymoreBaseMiner，ClaymoreZcash挖矿
                  - Dtsm.cs                        //继承Miner，Dtsm挖矿
                  - NhEqBase.cs                    //继承Miner，NiceHash Equihash挖矿基础类
                  - NhEqMiner.cs                   //继承NhEqBase，CPU、GPU挖矿
                  - OptiminerZcashMiner.cs         //继承Miner，Optiminer Zcash挖矿
            + ethminer                             //运行以太坊挖矿程序
                  - Ethereum.cs                    //
                  - MinerEtherum.cs                //继承Miner，基础类
                  - MinerEtherumCUDA.cs            //继承MinerEthereum，NVIDIA显卡挖矿
                  - MinerEtherumOCL.cs             //继承MinerEthereum，AMD显卡挖矿
            + Grouping                             //
                  - GrouppingLogic.cs              //
                  - GroupMiner.cs                  //
                  - GroupSetupUtils.cs             //
                  - MiningPaths.cs                 //定义挖矿程序路径，提供获取路径接口
                  - MiningDevice.cs                //提供设备算法收益相关接口
                  - MiningPair.cs                  //数据类型，设备&算法
                  - MiningSetup.cs                 //
            + Obsolete                             //
                  - cpuminer.cs                    //继承Miner，cpu挖矿
                  - eqm.cs                         //继承Miner，eqm挖矿
                  - Excavator.cs                   //继承Miner，excavator挖矿
            + Parsing                              //
                  - ExtraLaunchParameters.cs       //
                  - ExtraLaunchParametersParser.cs //
                  - MinerOption.cs                 //
                  - MinerOptionPackage.cs          //
            + XmrStak                              //
                  + Configs                        //
                        - XmrStakConfig.cs         //
                        - XmrStakConfigCpu.cs      //
                        - XmrStakConfigGpu.cs      //
                        - XmrStakConfigPool.cs     //
                  - XmrStak.cs                     //继承Miner，XmrStak程序挖矿
            - Ccminer.cs                           //继承Miner，NVIDIA挖矿，构造命令行
            - ClaymoreBaseMiner.cs                 //基类，继承Miner，提供Claymore挖矿相关方法
            - ClaymoreCryptoNightMiner.cs          //继承ClaymoreBaseMiner，CryptoNight算法挖矿
            - ClaymoreDual.cs                      //继承ClaymoreBaseMiner，Claymore多挖
            - Ewbf.cs                              //继承Miner，Ewbf挖矿
            - Miner.cs                             //基类，提供挖矿开始结束、信息查询等接口
            - MinerFactory.cs                      //根据算法和设备创建相应矿工
            - MinersApiPortsManager.cs             //提供端口判断接口，是否可用、获取、删除
            - MinersManager.cs                     //提供挖矿管理接口，使用MiningSession提供方法
            - MinersSettingsManager.cs             //继承ConfigFile，设置初始化等接口
            - MiningSession.cs                     //提供挖矿信息查询停止接口
            - Prospector.cs                        //继承Miner，Prospector挖矿
            - Sgminer.cs                           //继承Miner，sgminer AMD挖矿
            - Xmrig.cs                             //继承Miner，Xmrig挖矿
      + PInvoke
            - CPUID.cs                             //提供获取CPU名字、供应商、核心数等方法
            - NiceHashProcess.cs                   //进程相关启动、关闭、强杀等方法
            - PInvokeHelpers.cs
      + Resources                                  //png资源
      + Stats
            - ExchangeRateAPI.cs                   //提供获取BTC与USD换算利率接口
            - NiceHashSocket.cs                    //NiceHash socket连接方法
            - NiceHashStats.cs                     //数据统计和设置
      + Switching
            - AlgorithmHistory.cs                  //存储挖过算法信息
            - AlgorithmSwitchingManager.cs         //提供算法切换方法
            - Interval.cs
            - Models.cs
            - NHSmaData.cs
      + Utils
            - AlogrithmNiceHashNames.cs           //提供获取算法名称方法
            - BINS_CODEGEN.cs                     //定义挖矿算法可执行程序路径
            - BINS_CODEGEN_3rd.cs                 //
            - BitcoinAddress.cs                   //bitcoin地址、矿工名合法性检查方法
            - CommandLineParser.cs                //命令行语法剖析方法
            - DownloadSetup.cs                    //
            - Extensions.cs                       //
            - Helpers.cs                          //
            - Links.cs                            //
            - Logger.cs                           //
            - MemoryHelper.cs                     //
            - MinersDownloader.cs                 //
            - MinersDownloadManager.cs            //
            - MinersExistanceChecker.cs           //
            - ProfitabilityCalculator.cs          //
      - app.config
      - Globals.cs                                //提供挖矿URL方法和比特币地址方法
      - IFTTT.cs                                  //信息post到IFTTT平台
      - International.cs                          //语言获取
      - packages.config
      - Program.cs                                //主程序
      - Setting.cs

```

## 2.工作原理

- 提供支持算法列表
- 根据选择设备计算个算法算力并向NiceHash请求当前各算法与比特币换算率比较得到最有算法
- 根据预先设定挖矿程序路径构造程序执行命令并启动
- 挖矿

## 3. 与服务器交互

- 登录：`login`方法，携带版本号
- 设备状态更新：`devixes.status`方法，携带设备信息（设备名称，当前状态等）
- 证书设置：`credentials.set`方法，携带比特币地址，矿工名
- 获取当前汇率：`exchange_rates`方法（证书设置后也会自动下发）
- 获取当前账户余额：`balance`方法

## 4.注意

- NiceHash比特币地址：NiceHash钱包所谓的比特币地址并不是真正意义上上的比特币地址，只是NiceHash分配的类比特币地址，可理解为NiceHash是个银行，个人把挖矿所得以地址为账户放在NiceHash银行中，这样的好处是不必每次挖矿所得都要向矿工支付交易费用。