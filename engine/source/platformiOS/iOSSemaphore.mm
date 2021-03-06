//-----------------------------------------------------------------------------
// Torque
// Copyright GarageGames, LLC 2011
//-----------------------------------------------------------------------------

// platformSemaphore.h does not ask for any inter process communication,
// and the posix semaphores require a file to be created on disk.
// which could create annoyances if the appication crashes...
// so we'll just roll our own semaphore here.

// note: this is not a bulletproof solution to the starving problem...
// see: The Little Book of Semapores, by Allen B. Downey, at http://greenteapress.com/semaphores/

#include <pthread.h>
#include "platform/platform.h"
#include "platform/threads/semaphore.h"

class PlatformSemaphore
{
public:
   pthread_mutex_t mDarkroom;
//   pthread_mutex_t mFoyer; // second lock, to help control starving.
   pthread_cond_t  mCond;
   S32 count;
};

Semaphore::Semaphore(S32 initialCount)
{
   bool ok;
   PlatformSemaphore* semaphore = new PlatformSemaphore();
   ok = pthread_mutex_init(&semaphore->mDarkroom,NULL);
   AssertFatal(ok == 0,"Create semaphore failed at creating mutex mDarkroom.");
//   ok = pthread_mutex_init(&semaphore->mFoyer,NULL);
//   AssertFatal(ok != 0,"Create semaphore failed at creating mutex mFoyer.");
   ok = pthread_cond_init(&semaphore->mCond,NULL);
   AssertFatal(ok == 0,"Create semaphore failed at creating condition mCond.");
   
   semaphore->count = initialCount;
   mData = semaphore;
}

Semaphore::~Semaphore()
{
   pthread_mutex_destroy(&mData->mDarkroom);
//   pthread_mutex_destroy(&mData->mFoyer);
   pthread_cond_destroy(&mData->mCond);
   
   delete mData;
}

bool Semaphore::acquire( bool block, S32 timeoutMS )
{ 
	
   bool ok;
   AssertFatal(mData, "Semaphore::acquireSemaphore: invalid semaphore");
   
   ok = pthread_mutex_lock(&mData->mDarkroom);
   AssertFatal(ok == 0,"Mutex Lock failed on mDarkroom in acquireSemaphore().");
   
   if(mData->count <= 0 && !block) {
      ok = pthread_mutex_unlock(&mData->mDarkroom);
      AssertFatal(ok == 0,"Mutex Unlock failed on mDarkroom when not blocking in acquireSemaphore().");
      return false;
   }
   
   
   while( mData->count <= 0 )
   {
      ok = pthread_cond_wait(&mData->mCond, &mData->mDarkroom); // releases mDarkroom while blocked.
      AssertFatal(ok == 0,"Waiting on mCond failed in acquireSemaphore().");
   }   
   
   mData->count--;
   
   ok = pthread_mutex_unlock(&mData->mDarkroom);
   AssertFatal(ok == 0,"Mutex Unlock failed on mDarkroom when leaving acquireSemaphore().");
   
   return true;
}

void Semaphore::release()
{
   bool ok;
   AssertFatal(mData, "Semaphore::releaseSemaphore: invalid semaphore");
   
   ok = pthread_mutex_lock(&mData->mDarkroom);
   AssertFatal(ok == 0,"Mutex Lock failed on mDarkroom in releaseSemaphore().");   
   
   mData->count++;
   if(mData->count > 0) {
      ok = pthread_cond_signal(&mData->mCond);
      AssertFatal(ok == 0,"Signaling mCond failed in releaseSemaphore().");  
   }
   
   ok = pthread_mutex_unlock(&mData->mDarkroom);
    AssertFatal(ok == 0,"Mutex Unlock failed on mDarkroom when leaving releaseSemaphore().");
}
