//
//  ChatViewController.m
//  labChat
//
//  Created by Martin Winton on 7/9/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//

#import "ChatViewController.h"
#import "Parse.h"
#import "ChatCell.h"
#import "UIImageView+AFNetworking.h"

@interface ChatViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *chatMessageField;
@property (weak, nonatomic) IBOutlet UITableView *chatView;
@property (strong, nonatomic) NSArray *messages;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chatView.delegate = self;
    self.chatView.dataSource = self;
      [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:true];
    
    
  
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)sendAction:(id)sender {
    
    PFObject *chatMessage = [PFObject objectWithClassName:@"Message_fbu2018"];
    
    chatMessage[@"text"] = self.chatMessageField.text;
    chatMessage[@"user"] = PFUser.currentUser;

    [chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The message was saved!");
            self.chatMessageField.text = @"";
        } else {
            NSLog(@"Problem saving message: %@", error.localizedDescription);
        }
    }];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    PFObject *message = self.messages[indexPath.row];
    cell.chatLabel.text = message[@"text"];
    
    PFUser *user = message[@"user"];
    if (user != nil) {
        // User found! update username label with username
        cell.user.text = user.username;
        NSString *adorableAvatarURLString = [NSString stringWithFormat:@"%@%@%@", @"https://api.adorable.io/avatars/5",  cell.user.text, @".png"];
        NSURL *adorableAvatarURL = [NSURL URLWithString:adorableAvatarURLString];
        [cell.adorableAvatar setImageWithURL:adorableAvatarURL];
    } else {
        // No user found, set default username
        cell.user.text = @"🤖";
  
        
        NSString *adorableAvatarURLString = [NSString stringWithFormat:@"%@%@%@", @"https://api.adorable.io/avatars/5",  @"poop", @".png"];
        NSURL *adorableAvatarURL = [NSURL URLWithString:adorableAvatarURLString];
        
        
        [cell.adorableAvatar setImageWithURL:adorableAvatarURL];

    }
    
 
    

    return cell;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.messages.count;
    
    

    
    
}

- (void)onTimer {
  
    
    PFQuery *query = [PFQuery queryWithClassName:@"Message_fbu2018"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    query.limit = 20;
    
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.messages = posts;
        
            [self.chatView reloadData];
            // do something with the array of object returned by the call
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
@end
