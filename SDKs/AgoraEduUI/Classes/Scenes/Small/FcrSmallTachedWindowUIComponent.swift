//
//  FcrSmallWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/9.
//

import AgoraUIBaseViews
import AgoraEduCore
import Foundation

class FcrSmallTachedWindowUIComponent: UIViewController {
    let coHost: FcrCoHostTachedWindowUIComponent
    let teacher: FcrTeacherTachedWindowUIComponent
    
    private weak var delegate: FcrTachedStreamWindowUIComponentDelegate?
    
    init(roomController: AgoraEduRoomContext,
         userController: AgoraEduUserContext,
         streamController: AgoraEduStreamContext,
         mediaController: AgoraEduMediaContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrTachedStreamWindowUIComponentDelegate? = nil,
         componentDataSource: FcrUIComponentDataSource? = nil) {
        self.coHost = FcrCoHostTachedWindowUIComponent(roomController: roomController,
                                                       userController: userController,
                                                       streamController: streamController,
                                                       mediaController: mediaController,
                                                       subRoom: subRoom,
                                                       componentDataSource: componentDataSource)
        
        self.teacher = FcrTeacherTachedWindowUIComponent(roomController: roomController,
                                                         userController: userController,
                                                         streamController: streamController,
                                                         mediaController: mediaController,
                                                         subRoom: subRoom)
        
        super.init(nibName: nil,
                   bundle: nil)
        
        self.coHost.delegate = self
        self.teacher.delegate = self
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayout(_ layout: UICollectionViewFlowLayout) {
        
        let coHostLayout = UICollectionViewFlowLayout()
        coHostLayout.scrollDirection = .vertical
        coHostLayout.itemSize = CGSize(
            width: view.bounds.width,
            height: view.bounds.height / 2.0,
        )
        coHostLayout.minimumLineSpacing = 0
        coHostLayout.minimumInteritemSpacing = 0
        coHost.updateLayout(coHostLayout)
        
        
        let teacherLayout = UICollectionViewFlowLayout()
        teacherLayout.scrollDirection = .horizontal
        teacherLayout.itemSize = CGSize(
            width: view.bounds.width,
            height: view.bounds.height / 2.0,
        )
        teacherLayout.minimumLineSpacing = 0
        teacherLayout.minimumInteritemSpacing = 0
        teacher.updateLayout(teacherLayout)
        
        updateViewFrame()
    }
    
    func getRenderView(userId: String) -> FcrWindowRenderView? {
        if let renderView = teacher.getRenderView(userId: userId) {
            return renderView
        } else if let renderView = coHost.getRenderView(userId: userId) {
            return renderView
        }
        
        return nil
    }
    
    func getItem(streamId: String) -> FcrTachedWindowRenderViewState? {
        if let item = teacher.getItem(streamId: streamId) {
            return item
        } else if let item = coHost.getItem(streamId: streamId) {
            return item
        }
        
        return nil
    }
    
    func updateItem(_ item: FcrTachedWindowRenderViewState,
                    animation: Bool = true) {
        teacher.updateItem(item,
                           animation: animation)
        coHost.updateItem(item,
                          animation: animation)
    }
}

extension FcrSmallTachedWindowUIComponent: AgoraUIContentContainer, AgoraUIActivity {
    func initViews() {
        addChild(coHost)
        addChild(teacher)
        
        view.addSubview(coHost.view)
        view.addSubview(teacher.view)
        
        teacher.view.agora_enable = UIConfig.teacherVideo.enable
        teacher.view.agora_visible = UIConfig.teacherVideo.visible
        
        coHost.view.agora_enable = UIConfig.studentVideo.enable
        coHost.view.agora_visible = UIConfig.studentVideo.visible
    }
    
    func initViewFrame() {
        coHost.view.mas_makeConstraints { make in
            make?.left.top().right().bottom().equalTo()(0)
        }
        
        teacher.view.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(0)
            make?.right.equalTo()(coHost.view.mas_left)?.equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        
    }
    
    func viewWillActive() {
        coHost.viewWillActive()
        teacher.viewWillActive()
    }
    
    func viewWillInactive() {
        coHost.viewWillInactive()
        teacher.viewWillInactive()
    }
}

private extension FcrSmallTachedWindowUIComponent {
    func updateViewFrame() {
        let coHostCount = CGFloat(coHost.dataSource.count)
        let teacherCount = CGFloat(teacher.dataSource.count)
        let count = (teacherCount + coHostCount)
        
        let itemWidth = coHost.layout.itemSize.width
        let itemLineSpacing = coHost.layout.minimumLineSpacing
        
        let itemsWidth = (itemWidth + itemLineSpacing) * count - itemLineSpacing
        var firstItemX = (view.bounds.width - itemsWidth) * 0.5
        
        if firstItemX <= 0 {
            firstItemX = 0
        }
        
        let coHostLeft = (itemWidth + itemLineSpacing) * teacherCount + firstItemX
        
        print("###benco: coHostCount:\(coHostCount) teacherCount:\(teacherCount)")
        
        let radio = coHostCount <= 1 ? 0.5 : 0.4
        
        let teacherHeight = view.bounds.height * radio
        let coHostHeight = view.bounds.height - teacherHeight
        
        let itemSize: CGSize
        if coHostCount <= 1 {
            itemSize = CGSize(
                width: view.bounds.width,
                height: coHostHeight
            )
        } else if coHostCount == 2 {
            itemSize = CGSize(
                width: view.bounds.width,
                height: coHostHeight / 2
            )
        } else {
            itemSize = CGSize(
                width: view.bounds.width / 2.0,
                height: coHostHeight / 2
            )
        }
        
        let oldCoHostItemSize = (coHost.layout as UICollectionViewFlowLayout).itemSize
        if !oldCoHostItemSize.equalTo(itemSize) {
            let coHostLayout = UICollectionViewFlowLayout()
            coHostLayout.scrollDirection = .vertical
            
            coHostLayout.itemSize = itemSize
            coHostLayout.minimumLineSpacing = 0
            coHostLayout.minimumInteritemSpacing = 0
            coHost.updateLayout(coHostLayout)
            
            print("###benco: updateCoHost")
        }
        
        let oldTeacherItemSize = (teacher.layout as UICollectionViewFlowLayout).itemSize
        
        let teacherItemSize = CGSize(
            width: view.bounds.width,
            height: teacherHeight,
        )
        
        if !oldTeacherItemSize.equalTo(teacherItemSize) {
            let teacherLayout = UICollectionViewFlowLayout()
            teacherLayout.scrollDirection = .horizontal
            teacherLayout.itemSize = teacherItemSize
            teacherLayout.minimumLineSpacing = 0
            teacherLayout.minimumInteritemSpacing = 0
            teacher.updateLayout(teacherLayout)
            
            print("###benco: updateteacher")
        }
                
        coHost.view.mas_remakeConstraints { make in
            /*
            make?.top.right().bottom().equalTo()(0)
            make?.left.equalTo()(coHostLeft)
             */
            make?.left.right().bottom().equalTo()(0)
            make?.top.equalTo()(teacher.view.mas_bottom)
        }
        
        teacher.view.mas_remakeConstraints { make in
            /*
            make?.left.top().bottom().equalTo()(0)
            make?.right.equalTo()(coHost.view.mas_left)?.equalTo()(-itemLineSpacing)
             */
            make?.left.right().top().equalTo()(0)
            make?.height.equalTo()(view.mas_height)?.multipliedBy()(radio)
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        }
    }
}

extension FcrSmallTachedWindowUIComponent: FcrTachedStreamWindowUIComponentDelegate {
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       didDataSouceCountUpdated count: Int) {
        updateViewFrame()
    }
    
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       didPressItem item: FcrTachedWindowRenderViewState,
                                       view: UIView) {
        delegate?.tachedStreamWindowUIComponent(component,
                                                didPressItem: item,
                                                view: view)
    }
    
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       shouldItemIsHide streamId: String) -> Bool {
        return delegate?.tachedStreamWindowUIComponent(component,
                                                       shouldItemIsHide: streamId) ?? false
    }
}
