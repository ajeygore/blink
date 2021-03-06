////////////////////////////////////////////////////////////////////////////////
//
// B L I N K
//
// Copyright (C) 2016 Blink Mobile Shell Project
//
// This file is part of Blink.
//
// Blink is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Blink is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Blink. If not, see <http://www.gnu.org/licenses/>.
//
// In addition, Blink is also subject to certain additional terms under
// GNU GPL version 3 section 7.
//
// You should have received a copy of these additional terms immediately
// following the terms and conditions of the GNU General Public License
// which accompanied the Blink Source Code. If not, see
// <http://www.github.com/blinksh/blink>.
//
////////////////////////////////////////////////////////////////////////////////

#import <CommonCrypto/CommonDigest.h>

#import "PKCard.h"
#import "PKCardCreateViewController.h"
#import "PKCardDetailsViewController.h"
#import "PKCardViewController.h"


@interface PKCardViewController ()

@end

@implementation PKCardViewController {
  NSString *_clipboardPassphrase;
  SshRsa *_clipboardKey;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return PKCard.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

  PKCard *pk = [PKCard.all objectAtIndex:indexPath.row];

  // Configure the cell...
  cell.textLabel.text = pk.ID;
  cell.detailTextLabel.text = [self fingerprint:pk.publicKey];

  return cell;
}

- (NSString *)fingerprint:(NSString *)publicKey
{
  const char *str = [publicKey UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, (CC_LONG)strlen(str), result);

  NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [ret appendFormat:@"%02x:", result[i]];
  }
  [ret deleteCharactersInRange:NSMakeRange([ret length] - 1, 1)];
  return ret;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // Remove PKCard
    [PKCard.all removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:true];
    [PKCard saveIDS];
    [self.tableView reloadData];
  }
}

- (IBAction)addKey:(id)sender
{
  UIAlertController *keySourceController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
  UIAlertAction *generate = [UIAlertAction actionWithTitle:@"Create New"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                     _clipboardKey = nil;
                                                     [self performSegueWithIdentifier:@"createKeySegue" sender:sender];
                                                   }];
  UIAlertAction *import = [UIAlertAction actionWithTitle:@"Import from clipboard"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action) {
                                                   // ImportKey flow
                                                   [self importKey];

                                                   if (_clipboardKey) {
                                                     [self performSegueWithIdentifier:@"createKeySegue" sender:sender];
                                                   }                                                   
                                                 }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction *_Nonnull action){
                                                   //
                                                 }];

  [keySourceController addAction:generate];
  [keySourceController addAction:import];
  [keySourceController addAction:cancel];
  [[keySourceController popoverPresentationController] setBarButtonItem:sender];
  [self presentViewController:keySourceController animated:YES completion:nil];
}

- (void)importKey
{
  // Check if key is encrypted.
  UIPasteboard *pb = [UIPasteboard generalPasteboard];
  NSString *pbkey = pb.string;

  // Ask for passphrase if it is encrypted.
  if (([pbkey rangeOfString:@"ENCRYPTED"
                    options:NSRegularExpressionSearch]
         .location != NSNotFound)) {
    UIAlertController *passphraseRequest = [UIAlertController alertControllerWithTitle:@"Encrypted key"
                                                                               message:@"Please insert passphrase"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    [passphraseRequest addTextFieldWithConfigurationHandler:^(UITextField *textField) {
      textField.placeholder = NSLocalizedString(@"Enter passphrase", @"Passphrase");
      textField.secureTextEntry = YES;
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *_Nonnull action) {
                                                 // Create a key
                                                 UITextField *passphrase = passphraseRequest.textFields.lastObject;
                                                 SshRsa *key = [[SshRsa alloc] initFromPrivateKey:pbkey passphrase:passphrase.text];
                                                 if (key == nil) {
                                                   // Retry
                                                   [self importKey];
                                                 } else {
                                                   _clipboardKey = key;
                                                   _clipboardPassphrase = passphrase.text;
                                                   [self performSegueWithIdentifier:@"createKeySegue" sender:passphraseRequest];
                                                 }
                                               }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action){
                                                   }];
    [passphraseRequest addAction:ok];
    [passphraseRequest addAction:cancel];
    [self presentViewController:passphraseRequest animated:YES completion:nil];

  } else {
    // If the key isn't encrypted, then try to generate it and go to the create key dialog to complete
    SshRsa *key = [[SshRsa alloc] initFromPrivateKey:pbkey passphrase:nil];
    
    if (key == nil) {
      UIAlertView *errorAlert = [[UIAlertView alloc]
            initWithTitle:@"Invalid Key"
                  message:@"Clipboard content couldn't be validated as a key"
                 delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
      [errorAlert show];
    } else {
      _clipboardKey = key;
      _clipboardPassphrase = nil;
    }
  }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  if ([[segue identifier] isEqualToString:@"keyInfoSegue"]) {
    PKCardDetailsViewController *details = segue.destinationViewController;

    NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
    PKCard *pkcard = [PKCard.all objectAtIndex:indexPath.row];
    details.pkcard = pkcard;
    return;
  }
  if ([[segue identifier] isEqualToString:@"createKeySegue"]) {
    PKCardCreateViewController *create = segue.destinationViewController;

    if (_clipboardKey) {
      create.key = _clipboardKey;
      create.passphrase = _clipboardPassphrase;
    }

    return;
  }
}

- (IBAction)unwindFromCreate:(UIStoryboardSegue *)sender
{
  NSIndexPath *newIdx = [NSIndexPath indexPathForRow:(PKCard.count - 1) inSection:0];
  [self.tableView insertRowsAtIndexPaths:@[ newIdx ] withRowAnimation:UITableViewRowAnimationBottom];
}

- (IBAction)unwindFromDetails:(UIStoryboardSegue *)sender
{
  NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
  [self.tableView reloadRowsAtIndexPaths:@[ selection ] withRowAnimation:UITableViewRowAnimationNone];
}

@end
